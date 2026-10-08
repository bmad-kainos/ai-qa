[CmdletBinding()]
param(
    [Parameter(Position = 0)][ValidateSet('install', 'update', 'verify', 'uninstall')][string]$Command = 'install',
    [Parameter(Position = 1)][string]$Target = '.',
    [string]$Prefix = 'qa',
    [switch]$DryRun,
    [switch]$Purge,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
$Encoding = New-Object System.Text.UTF8Encoding($false)
$ScriptDir = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$SourceRoot = Join-Path $ScriptDir '.github'
$Version = (Get-Content -LiteralPath (Join-Path $ScriptDir 'VERSION') -Raw).Trim()
$ManifestRel = '.github/ai-qa/manifest.json'
$Begin = '<!-- ai-qa:start -->'; $End = '<!-- ai-qa:end -->'
$IgnoreBegin = '# ai-qa:start'; $IgnoreEnd = '# ai-qa:end'
$PrefixExplicit = $PSBoundParameters.ContainsKey('Prefix')

function Fail([string]$Message) { throw $Message }
function HashBytes([byte[]]$Bytes) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function HashFile([string]$Path) { return HashBytes ([System.IO.File]::ReadAllBytes($Path)) }
function IsLink([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    return [bool]((Get-Item -LiteralPath $Path -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}
function SafePath([string]$Relative) {
    if ([IO.Path]::IsPathRooted($Relative) -or $Relative -match '(^|/)\.\.(/|$)' -or $Relative.Contains('|')) { Fail "Unsafe manifest path: $Relative" }
    if ($Relative -notmatch '^\.github/(agents/|skills/|ai-qa/framework/|ai-qa/manifest\.json$|copilot-instructions\.md$)' -and
        $Relative -notmatch '^\.gitignore$|^\.github/ai-qa/(project|baselines)(/|$)|^qa-work(/|$)') { Fail "Unsafe path: $Relative" }
    $path = $ResolvedTarget
    foreach ($part in ($Relative -split '/')) { $path = Join-Path $path $part; if (IsLink $path) { Fail "Refusing symlink: $path" } }
    return $path
}
function AssertNoLinks([string]$Path) {
    if (IsLink $Path) { Fail "Refusing symlink: $Path" }
    if (Test-Path -LiteralPath $Path -PathType Container) {
        $links = @(Get-ChildItem -LiteralPath $Path -Force -Recurse | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint })
        if ($links.Count) { Fail "Refusing symlink in managed path: $($links[0].FullName)" }
    }
}
function GetBlock([string]$Text, [string]$Start, [string]$Finish) {
    $a = [regex]::Matches($Text, [regex]::Escape($Start)).Count
    $b = [regex]::Matches($Text, [regex]::Escape($Finish)).Count
    if ($a -ne $b -or $a -gt 1) { Fail 'Invalid AI-QA markers' }
    if ($a -eq 0) { return $null }
    $first = $Text.IndexOf($Start, [StringComparison]::Ordinal)
    $last = $Text.IndexOf($Finish, $first, [StringComparison]::Ordinal) + $Finish.Length
    return $Text.Substring($first, $last - $first)
}
function MergeBlock([string]$Text, [string]$Start, [string]$Finish, [string]$Replacement, [bool]$Remove, [bool]$Eol) {
    $block = GetBlock $Text $Start $Finish
    if ($null -ne $block) {
        $index = $Text.IndexOf($block, [StringComparison]::Ordinal)
        $before = $Text.Substring(0, $index); $after = $Text.Substring($index + $block.Length)
        if (-not $Remove) { return $before + $Replacement + $after }
        if ($after.StartsWith("`r`n")) { $after = $after.Substring(2) } elseif ($after.StartsWith("`n")) { $after = $after.Substring(1) }
        # Drop the blank separator line the installer added before the block.
        if ($before.EndsWith("`n`n")) { $before = $before.Substring(0, $before.Length - 1) }
        $result = $before + $after
        if (-not $Eol) { $result = $result.TrimEnd("`r", "`n") }
        return $result
    }
    if ($Remove) { return $Text }
    if ($Text.Length -eq 0) { return $Replacement + "`n" }
    if (-not $Text.EndsWith("`n")) { $Text += "`n" }
    return $Text + "`n" + $Replacement + "`n"
}
function VersionGreater([string]$A, [string]$B) {
    $x = $A.Split('.'); $y = $B.Split('.')
    for ($i = 0; $i -lt [Math]::Max($x.Count, $y.Count); $i++) {
        $p = if ($i -lt $x.Count) { [int]$x[$i] } else { 0 }; $q = if ($i -lt $y.Count) { [int]$y[$i] } else { 0 }
        if ($p -gt $q) { return $true }; if ($p -lt $q) { return $false }
    }
    return $false
}
function EndsWithEol([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return '1' }
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -eq 0 -or $bytes[$bytes.Length - 1] -eq 10) { return '1' } else { return '0' }
}
function ReadManifest([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    try { $data = [IO.File]::ReadAllText($Path, $Encoding) | ConvertFrom-Json } catch { Fail "Invalid install manifest: $Path" }
    if ($data.schema -ne 1 -or $data.prefix -notmatch '^[A-Za-z0-9_-]+$' -or
        $data.framework_version -notmatch '^\S+$' -or $data.instructions_block_sha256 -notmatch '^[0-9a-f]{64}$' -or
        $data.gitignore_block_sha256 -notmatch '^[0-9a-f]{64}$') { Fail "Invalid install manifest: $Path" }
    foreach ($property in $data.files.PSObject.Properties) {
        $name = $property.Name
        if ($property.Value -notmatch '^[0-9a-f]{64}$' -or
            ($name -notmatch ('^\.github/agents/' + [regex]::Escape($data.prefix) + '[^/]*\.agent\.md$') -and
             $name -notmatch ('^\.github/skills/' + [regex]::Escape($data.prefix) + '-[^/]+/.+$') -and
             $name -notmatch '^\.github/ai-qa/framework/.+$')) { Fail "Unsafe manifest file: $name" }
        $null = SafePath $name
    }
    return $data
}
function WriteManifest([string]$Path, $Data) {
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('{'); $lines.Add('  "schema": 1,')
    $lines.Add(('  "framework_version": "{0}",' -f $Data.framework_version))
    $lines.Add(('  "prefix": "{0}",' -f $Data.prefix))
    $lines.Add(('  "instructions_block_sha256": "{0}",' -f $Data.instructions_block_sha256))
    $lines.Add(('  "gitignore_block_sha256": "{0}",' -f $Data.gitignore_block_sha256))
    $lines.Add(('  "instructions_eol": "{0}",' -f $Data.instructions_eol))
    $lines.Add(('  "gitignore_eol": "{0}",' -f $Data.gitignore_eol))
    $lines.Add('  "created_files": [')
    foreach ($createdFile in @($Data.created_files | Sort-Object)) { $lines.Add(('    "{0}",' -f $createdFile)) }
    if ($Data.created_files.Count -gt 0) { $lines[$lines.Count - 1] = $lines[$lines.Count - 1].TrimEnd(',') }
    $lines.Add('  ],')
    $lines.Add('  "created_dirs": [')
    foreach ($directory in @($Data.created_dirs | Sort-Object -Unique)) { $lines.Add(('    "{0}",' -f $directory)) }
    if ($Data.created_dirs.Count -gt 0) { $lines[$lines.Count - 1] = $lines[$lines.Count - 1].TrimEnd(',') }
    $lines.Add('  ],')
    $lines.Add('  "files": {')
    $names = @($Data.files.Keys | Sort-Object)
    for ($i = 0; $i -lt $names.Count; $i++) {
        $comma = if ($i -lt $names.Count - 1) { ',' } else { '' }
        $lines.Add(('    "{0}": "{1}"{2}' -f $names[$i], $Data.files[$names[$i]], $comma))
    }
    $lines.Add('  }'); $lines.Add('}')
    [IO.File]::WriteAllText($Path, (($lines -join "`n") + "`n"), $Encoding)
}

try {
    if (-not $Version) { Fail 'VERSION is empty' }
    if ($Prefix -notmatch '^[A-Za-z0-9_-]+$') { Fail 'Prefix must contain only letters, digits, underscores and hyphens' }
    if ($Purge -and $Command -ne 'uninstall') { Fail '--purge requires uninstall' }
    if (-not (Test-Path -LiteralPath $Target -PathType Container)) { Fail "Target is not a directory: $Target" }
    if (IsLink $Target) { Fail "Refusing symlink target: $Target" }
    $ResolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    if ($Command -ne 'verify' -and ($ResolvedTarget -eq $ScriptDir -or
        ((Test-Path (Join-Path $ResolvedTarget 'install.sh')) -and (Test-Path (Join-Path $ResolvedTarget '.github/ai-qa/framework'))))) {
        Fail 'Refusing to modify the AI-QA source repository itself'
    }
    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) { Fail 'Missing .github framework folder next to installer' }
    $ManifestPath = SafePath $ManifestRel
    $Manifest = ReadManifest $ManifestPath
    if ($Command -in @('update', 'uninstall') -and -not $Manifest) { Fail "No managed installation to $Command" }
    if ($Command -eq 'install' -and $Manifest) { Fail 'Already installed; use update or verify' }
    if ($Command -eq 'update' -and -not $PrefixExplicit) { $Prefix = $Manifest.prefix }
    if ($Manifest -and $Command -ne 'uninstall' -and $Prefix -ne $Manifest.prefix) { Fail "Installed prefix is '$($Manifest.prefix)'; use the same -Prefix" }

    if ($Command -eq 'verify') {
        if (-not $Manifest) { Fail 'AI-QA manifest missing' }
        $problems = [Collections.Generic.List[string]]::new()
        foreach ($property in $Manifest.files.PSObject.Properties) {
            $path = SafePath $property.Name
            if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or (HashFile $path) -ne $property.Value) { $problems.Add($property.Name) }
        }
        $instructionPath = SafePath '.github/copilot-instructions.md'; $ignorePath = SafePath '.gitignore'
        $instructionText = if (Test-Path $instructionPath) { [IO.File]::ReadAllText($instructionPath, $Encoding) } else { '' }
        $ignoreText = if (Test-Path $ignorePath) { [IO.File]::ReadAllText($ignorePath, $Encoding) } else { '' }
        $instructionBlock = GetBlock $instructionText $Begin $End; $ignoreBlock = GetBlock $ignoreText $IgnoreBegin $IgnoreEnd
        if ($null -eq $instructionBlock -or (HashBytes $Encoding.GetBytes((($instructionBlock -replace "`r`n", "`n") + "`n"))) -ne $Manifest.instructions_block_sha256) { $problems.Add('copilot-instructions.md (managed block)') }
        if ($null -eq $ignoreBlock -or (HashBytes $Encoding.GetBytes((($ignoreBlock -replace "`r`n", "`n") + "`n"))) -ne $Manifest.gitignore_block_sha256) { $problems.Add('.gitignore (managed block)') }
        if ($problems.Count) { Fail "Verification failed: $($problems -join ', ')" }
        if ($Manifest.framework_version -ne $Version) { Write-Warning "Installed framework version $($Manifest.framework_version) differs from source $Version" }
        if (-not (Test-Path (SafePath '.github/ai-qa/project/project.md') -PathType Leaf)) { Write-Output 'WARN: project layer is not configured; run qa-configure' }
        Write-Output "Verified AI-QA framework $($Manifest.framework_version), $(@($Manifest.files.PSObject.Properties).Count) files and instruction blocks"
        exit 0
    }
    if ($Purge -and -not $Yes) {
        if ([Console]::IsInputRedirected) { Fail '--purge requires confirmation; use -Yes for non-interactive use' }
        $name = Split-Path -Leaf $ResolvedTarget
        $answer = Read-Host "Purge project data and qa-work from $name? Type yes"
        if ($answer -ne 'yes') { Fail 'Purge not confirmed' }
    }
    if ($Purge) { foreach ($rel in @('.github/ai-qa/project', '.github/ai-qa/baselines', 'qa-work')) { AssertNoLinks (Join-Path $ResolvedTarget $rel) } }

    $oldFiles = @{}
    if ($Manifest) { foreach ($property in $Manifest.files.PSObject.Properties) { $oldFiles[$property.Name] = $property.Value } }
    $desired = @{}
    if ($Command -ne 'uninstall') {
        foreach ($folder in @('agents', 'skills', 'ai-qa/framework')) { AssertNoLinks (Join-Path $SourceRoot $folder) }
        $rename = @{}
        if ($Prefix -ne 'qa') {
            foreach ($file in (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'agents') -Filter 'qa*.agent.md' -File -Recurse -ErrorAction SilentlyContinue)) {
                $name = [IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetFileNameWithoutExtension($file.Name)); $rename[$name] = $Prefix + $name.Substring(2)
            }
            foreach ($folder in (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'skills') -Directory -Filter 'qa-*' -ErrorAction SilentlyContinue)) { $rename[$folder.Name] = $Prefix + $folder.Name.Substring(2) }
        }
        $prunedPacks = @()
        $prunedFile = Join-Path $ResolvedTarget '.github/ai-qa/project/pruned-packs.txt'
        if (Test-Path -LiteralPath $prunedFile -PathType Leaf) { $prunedPacks = @(Get-Content -LiteralPath $prunedFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^[A-Za-z0-9_-]+$' }) }
        $items = @()
        $items += Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'agents') -Filter 'qa*.agent.md' -File -Recurse -ErrorAction SilentlyContinue
        foreach ($folder in (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'skills') -Directory -Filter 'qa-*' -ErrorAction SilentlyContinue)) { $items += Get-ChildItem -LiteralPath $folder.FullName -File -Recurse }
        $items += Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'ai-qa/framework') -File -Recurse
        foreach ($item in $items) {
            if (IsLink $item.FullName) { Fail "Refusing symlink source: $($item.FullName)" }
            $tail = $item.FullName.Substring($SourceRoot.Length + 1).Replace('\', '/')
            if ($tail -match '^ai-qa/framework/packs/([^/]+)/' -and $Matches[1] -ne '_TEMPLATE' -and $prunedPacks -contains $Matches[1]) { continue }
            if ($tail -match '^agents/qa') { $tail = $tail -replace '^agents/qa', "agents/$Prefix" }
            elseif ($tail -match '^skills/qa-') { $tail = $tail -replace '^skills/qa-', "skills/$Prefix-" }
            $bytes = [IO.File]::ReadAllBytes($item.FullName)
            if ($Prefix -ne 'qa' -and $item.Extension -in @('.md', '.txt', '.json', '.yaml', '.yml')) {
                $text = $Encoding.GetString($bytes)
                foreach ($old in ($rename.Keys | Sort-Object Length -Descending)) {
                    $pattern = '(?<![A-Za-z0-9_-])' + [regex]::Escape($old) + '(?![A-Za-z0-9_-])'
                    $replacement = $rename[$old]
                    $text = [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement })
                }
                $bytes = $Encoding.GetBytes($text)
            }
            $desired['.github/' + $tail] = $bytes
        }
        if (-not $desired.Count) { Fail 'No framework-owned files found in .github' }
    }

    $collisions = [Collections.Generic.List[string]]::new(); $plan = [Collections.Generic.List[object]]::new()
    $newFiles = @{}; $modified = [Collections.Generic.List[string]]::new()
    if ($Command -ne 'uninstall') {
        foreach ($category in @('agents', 'instructions')) {
            if ($category -eq 'instructions' -and $Prefix -ne 'qa') { continue }
            $folder = Join-Path $ResolvedTarget ".github/$category"
            if (IsLink $folder) { Fail "Refusing symlink: $folder" }
            if (Test-Path -LiteralPath $folder -PathType Container) {
                $pattern = if ($category -eq 'agents') { "$Prefix*.agent.md" } else { "$Prefix*.instructions.md" }
                foreach ($file in (Get-ChildItem -LiteralPath $folder -Filter $pattern -File)) { $rel = ".github/$category/$($file.Name)"; if (-not $oldFiles.ContainsKey($rel)) { $collisions.Add("$rel (occupied namespace)") } }
            }
        }
        $skillFolder = Join-Path $ResolvedTarget '.github/skills'
        if (IsLink $skillFolder) { Fail "Refusing symlink: $skillFolder" }
        if (Test-Path -LiteralPath $skillFolder -PathType Container) {
            foreach ($folder in (Get-ChildItem -LiteralPath $skillFolder -Directory -Filter "$Prefix-*")) {
                $rel = ".github/skills/$($folder.Name)/"; if (-not @($oldFiles.Keys | Where-Object { $_.StartsWith($rel, [StringComparison]::Ordinal) }).Count) { $collisions.Add("$rel (occupied namespace)") }
            }
        }
    }
    foreach ($rel in $desired.Keys) {
        $path = SafePath $rel; $newHash = HashBytes $desired[$rel]
        if ($oldFiles.ContainsKey($rel)) {
            if ((Test-Path -LiteralPath $path -PathType Leaf) -and (HashFile $path) -eq $newHash) { $newFiles[$rel] = $newHash }
            elseif ((Test-Path -LiteralPath $path -PathType Leaf) -and (HashFile $path) -eq $oldFiles[$rel]) { $plan.Add(@{ action='write'; path=$rel; bytes=$desired[$rel] }); $newFiles[$rel]=$newHash }
            else {
                $modified.Add($rel); $review = SafePath ($rel + '.ai-qa-new')
                if ((Test-Path $review) -and (HashFile $review) -ne $newHash) { Fail "Refusing to overwrite existing review copy: $review" }
                $plan.Add(@{ action='write'; path=($rel + '.ai-qa-new'); bytes=$desired[$rel] }); $newFiles[$rel]=$oldFiles[$rel]
            }
        } elseif (Test-Path -LiteralPath $path) { $collisions.Add($rel) }
        else { $plan.Add(@{ action='write'; path=$rel; bytes=$desired[$rel] }); $newFiles[$rel]=$newHash }
    }
    foreach ($rel in $oldFiles.Keys) {
        if ($Command -eq 'uninstall' -or -not $desired.ContainsKey($rel)) {
            $path=SafePath $rel
            if ((Test-Path $path -PathType Leaf) -and (HashFile $path) -eq $oldFiles[$rel]) { $plan.Add(@{action='remove';path=$rel}) }
            elseif (Test-Path $path) { $modified.Add($rel) }
        }
    }

    $pointer = @($Begin, "AI-QA agents: @$Prefix and @$Prefix-configure.", 'Framework: .github/ai-qa/framework/.', "Project layer: .github/ai-qa/project/ (written only by $Prefix-configure).", 'Safety: .github/ai-qa/framework/method/safety.md.', $End) -join "`n"
    $ignore = @($IgnoreBegin, 'qa-work/**', '!qa-work/*/', '!qa-work/*/index.md', '!qa-work/*/outputs/', '!qa-work/*/outputs/**', $IgnoreEnd) -join "`n"
    $blockHash = HashBytes $Encoding.GetBytes($pointer + "`n"); $ignoreHash = HashBytes $Encoding.GetBytes($ignore + "`n")
    $insCreated = if ($Manifest) { [string](@($Manifest.created_files) -contains '.github/copilot-instructions.md') } elseif (Test-Path (SafePath '.github/copilot-instructions.md')) { 'False' } else { 'True' }
    $gitCreated = if ($Manifest) { [string](@($Manifest.created_files) -contains '.gitignore') } elseif (Test-Path (SafePath '.gitignore')) { 'False' } else { 'True' }
    $insEol = if ($Manifest -and $Manifest.instructions_eol) { [string]$Manifest.instructions_eol } elseif ($Manifest) { '1' } else { EndsWithEol (SafePath '.github/copilot-instructions.md') }
    $gitEol = if ($Manifest -and $Manifest.gitignore_eol) { [string]$Manifest.gitignore_eol } elseif ($Manifest) { '1' } else { EndsWithEol (SafePath '.gitignore') }
    $blockHashes = @{}; $definitions = @(
        @{path='.github/copilot-instructions.md';start=$Begin;finish=$End;replacement=$pointer;hash=$blockHash;old=$(if($Manifest){$Manifest.instructions_block_sha256});created=$insCreated;eol=($insEol -eq '1')},
        @{path='.gitignore';start=$IgnoreBegin;finish=$IgnoreEnd;replacement=$ignore;hash=$ignoreHash;old=$(if($Manifest){$Manifest.gitignore_block_sha256});created=$gitCreated;eol=($gitEol -eq '1')}
    )
    foreach ($entry in $definitions) {
        $path=SafePath $entry.path; $text=if(Test-Path $path){[IO.File]::ReadAllText($path,$Encoding)}else{''}; $current=GetBlock $text $entry.start $entry.finish
        if ($Manifest -and ($null -eq $current -or (HashBytes $Encoding.GetBytes((($current -replace "`r`n", "`n") + "`n"))) -ne $entry.old)) {
            $modified.Add("$($entry.path) (managed block)")
            if ($Command -ne 'uninstall') { $plan.Add(@{action='write';path=($entry.path+'.ai-qa-new');bytes=$Encoding.GetBytes($entry.replacement+"`n")}) }
            continue
        }
        if (-not $Manifest -and $null -ne $current) { $collisions.Add("$($entry.path) (existing markers)"); continue }
        $blockHashes[$entry.path]=if($Command -eq 'uninstall'){$entry.old}else{$entry.hash}
        $newText=MergeBlock $text $entry.start $entry.finish $entry.replacement ($Command -eq 'uninstall') $entry.eol
        if ($Command -eq 'uninstall') {
            if ($entry.created -eq 'True' -and -not $newText.Trim()) { $plan.Add(@{action='remove';path=$entry.path}) }
            elseif ($newText -ne $text) { $plan.Add(@{action='write';path=$entry.path;bytes=$Encoding.GetBytes($newText)}) }
        } else { $plan.Add(@{action='write';path=$entry.path;bytes=$Encoding.GetBytes($newText)}) }
    }
    if ($collisions.Count) { Fail "Conflicting or modified files (left untouched): $($collisions -join ', ')" }
    if ($Command -eq 'uninstall') {
        $plan.Add(@{action='remove';path=$ManifestRel})
        if ($Purge) { foreach($rel in @('.github/ai-qa/project','.github/ai-qa/baselines','qa-work')){$plan.Add(@{action='purge';path=$rel})} }
    }
    $createdDirs = @(); if ($Manifest) { $createdDirs += @($Manifest.created_dirs) }
    foreach ($entry in $plan | Where-Object action -eq 'write') {
        $parent = Split-Path -Parent $entry.path
        while ($parent -and -not (Test-Path (Join-Path $ResolvedTarget $parent))) {
            $createdDirs += $parent.Replace('\', '/'); $parent = Split-Path -Parent $parent
        }
    }
    $parent = Split-Path -Parent $ManifestRel
    while ($parent -and -not (Test-Path (Join-Path $ResolvedTarget $parent))) {
        $createdDirs += $parent.Replace('\', '/'); $parent = Split-Path -Parent $parent
    }
    $createdDirs = @($createdDirs | Sort-Object -Unique)
    if ($DryRun) { foreach($entry in $plan){Write-Output "[dry-run] $($entry.action) $(Join-Path $ResolvedTarget $entry.path)"}; foreach($item in $modified){Write-Output "[dry-run] preserve modified $item"}; if($Command -ne 'uninstall'){Write-Output "[dry-run] write $ManifestPath"}; exit 0 }
    foreach ($entry in $plan) {
        $path=SafePath $entry.path
        switch($entry.action){
            write {$parent=Split-Path -Parent $path;if(-not(Test-Path $parent)){$null=New-Item -ItemType Directory -Path $parent -Force};[IO.File]::WriteAllBytes($path,$entry.bytes)}
            remove {if(Test-Path $path){Remove-Item -LiteralPath $path -Force}}
            purge {if(Test-Path $path){AssertNoLinks $path;Remove-Item -LiteralPath $path -Recurse -Force}}
        }
    }
    if ($Command -eq 'uninstall') {
        foreach ($relative in ($createdDirs | Sort-Object { ($_ -split '/').Count } -Descending)) {
            $directory = SafePath $relative
            if ((Test-Path -LiteralPath $directory -PathType Container) -and
                -not (Get-ChildItem -LiteralPath $directory -Force | Select-Object -First 1)) {
                Remove-Item -LiteralPath $directory -Force
            }
        }
        Write-Output 'Uninstalled AI-QA framework assets'; foreach($item in $modified){Write-Output "Preserved modified $item"}; exit 0
    }
    $createdFiles = @(); if ($insCreated -eq 'True') { $createdFiles += '.github/copilot-instructions.md' }; if ($gitCreated -eq 'True') { $createdFiles += '.gitignore' }
    $manifestData=@{schema=1;framework_version=$Version;prefix=$Prefix;instructions_block_sha256=$(if($blockHashes.ContainsKey('.github/copilot-instructions.md')){$blockHashes['.github/copilot-instructions.md']}else{$Manifest.instructions_block_sha256});gitignore_block_sha256=$(if($blockHashes.ContainsKey('.gitignore')){$blockHashes['.gitignore']}else{$Manifest.gitignore_block_sha256});created_files=@($createdFiles);files=$newFiles;created_dirs=$createdDirs;instructions_eol=$insEol;gitignore_eol=$gitEol}
    $null=New-Item -ItemType Directory -Path (Split-Path -Parent $ManifestPath) -Force; WriteManifest $ManifestPath $manifestData
    foreach($item in $modified){Write-Output "Preserved modified $item; review .ai-qa-new if present"}
    if($Command -eq 'update'){
        Write-Output "Updated $($newFiles.Count) AI-QA framework files"
        $migration=Join-Path $ScriptDir 'docs/migrations.md';if(Test-Path $migration){$needsRefresh=$false;foreach($match in (Select-String $migration -Pattern '^\s*refresh-required:\s*([0-9.]+)')){$v=$match.Matches[0].Groups[1].Value;if((VersionGreater $v $Manifest.framework_version) -and -not (VersionGreater $v $Version)){$needsRefresh=$true}};if($needsRefresh){Write-Output "`nThis update requires qa-configure refresh (see docs/migrations.md)."}}
    } else {Write-Output "Installed $($newFiles.Count) AI-QA framework files"}
} catch { [Console]::Error.WriteLine("Error: $($_.Exception.Message)"); exit 1 }