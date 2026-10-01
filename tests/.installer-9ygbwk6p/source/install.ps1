param(
    [Parameter(Position = 0)][string]$Command = 'install',
    [Parameter(Position = 1)][string]$Target = '.',
    [string]$Prefix = 'qa',
    [Alias('dry-run')][switch]$DryRun,
    [switch]$Update,
    [switch]$Uninstall,
    [switch]$Purge,
    [switch]$Yes,
    [switch]$Verify
)

$ErrorActionPreference = 'Stop'
$begin = '<!-- ai-qa:start -->'
$end = '<!-- ai-qa:end -->'
$block = "$begin`nAI-QA agents: ``.github/agents/qa.agent.md`` and ``.github/agents/qa-configure.agent.md``.`n$end"
$ignoreBegin = '# ai-qa:start'
$ignoreEnd = '# ai-qa:end'
$ignoreBlock = ($ignoreBegin, 'qa-work/**', '!qa-work/*/', '!qa-work/*/index.md',
                '!qa-work/*/outputs/', '!qa-work/*/outputs/**', $ignoreEnd) -join "`n"
$frameworkVersion = '1.0.0'
$encoding = New-Object System.Text.UTF8Encoding($false)
$source = (Resolve-Path -LiteralPath $PSScriptRoot).Path

function Hash-Bytes([byte[]]$bytes) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Hash-Text([string]$text) { return Hash-Bytes $encoding.GetBytes($text) }
function Read-Text([string]$path) { return [System.IO.File]::ReadAllText($path, $encoding) }
function Write-Text([string]$path, [string]$text) { [System.IO.File]::WriteAllText($path, $text, $encoding) }
function Safe-Path([string]$relative) {
    if (($relative -notmatch '^\.github/' -and $relative -ne '.gitignore') -or
        $relative -match '(^|/)\.\.(/|$)' -or [System.IO.Path]::IsPathRooted($relative)) {
        throw "Unsafe manifest path: $relative"
    }
    $path = $resolvedTarget
    foreach ($part in ($relative -split '/')) {
        $path = Join-Path $path $part
        if (Test-Path -LiteralPath $path) {
            $item = Get-Item -LiteralPath $path -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "Refusing symlink: $path" }
        }
    }
    return $path
}
function Managed-Block([string]$path, [string]$start = $begin, [string]$finish = $end) {
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    $text = Read-Text $path
    $starts = ([regex]::Matches($text, [regex]::Escape($start))).Count
    $ends = ([regex]::Matches($text, [regex]::Escape($finish))).Count
    if ($starts -ne $ends -or $starts -gt 1) { throw "Invalid AI-QA markers in $path" }
    if ($starts -eq 0) { return $null }
    $first = $text.IndexOf($start, [StringComparison]::Ordinal)
    $last = $text.IndexOf($finish, $first, [StringComparison]::Ordinal) + $finish.Length
    return $text.Substring($first, $last - $first)
}

try {
    if ($Command -in @('install', 'update', 'verify', 'uninstall', 'purge')) {
        if ($Command -eq 'update') { $Update = $true }
        if ($Command -eq 'verify') { $Verify = $true }
        if ($Command -in @('uninstall', 'purge')) { $Uninstall = $true }
        if ($Command -eq 'purge') { $Purge = $true }
    } elseif ($Target -eq '.') {
        $Target = $Command
    } else { throw "Unknown command: $Command" }
    if ($Prefix -notmatch '^[a-zA-Z0-9_-]+$') { throw 'Prefix must contain only letters, digits, underscores and hyphens' }
    $block = $block.Replace('.github/agents/qa', ".github/agents/$Prefix")
    if ($Purge -and -not $Uninstall) { throw '--purge requires --uninstall' }
    if ($Purge -and -not $Yes -and -not $DryRun) {
        throw '--purge deletes project data and baselines; rerun with --yes to confirm'
    }
    if ([int]$Update.IsPresent + [int]$Uninstall.IsPresent + [int]$Verify.IsPresent -gt 1) {
        throw '--update, --uninstall and --verify are mutually exclusive'
    }
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    if (-not (Test-Path -LiteralPath $resolvedTarget -PathType Container)) { throw "Target is not a directory: $Target" }
    if ($resolvedTarget -eq $source -and -not $Verify) { throw 'Refusing to modify the AI-QA source repository itself' }
    $manifestPath = Safe-Path '.github/ai-qa/manifest.json'
    $instructionPath = Safe-Path '.github/copilot-instructions.md'
    $ignorePath = Safe-Path '.gitignore'
    $old = $null
    if (Test-Path -LiteralPath $manifestPath) {
        $old = Read-Text $manifestPath | ConvertFrom-Json
        if ($old.version -ne 1 -or $null -eq $old.files) { throw "Invalid install manifest: $manifestPath" }
        if ($old.prefix -notmatch '^[a-zA-Z0-9_-]+$') { throw 'Invalid manifest prefix' }
        if ($old.block -notmatch '^[0-9a-f]{64}$' -or $old.ignore_block -notmatch '^[0-9a-f]{64}$') {
            throw 'Invalid manifest block checksum'
        }
        if (-not $old.framework_version) { throw 'Invalid manifest framework version' }
    }
    $previous = @{}
    if ($old) {
        foreach ($property in $old.files.PSObject.Properties) {
            $null = Safe-Path $property.Name
            if ($property.Value -notmatch '^[0-9a-f]{64}$') { throw "Invalid manifest checksum: $($property.Name)" }
            $namespace = [regex]::Escape($old.prefix)
            if ($property.Name -notmatch "^\.github/agents/$namespace" + '[^/]*\.agent\.md$' -and
                $property.Name -notmatch "^\.github/skills/$namespace" + '-[^/]+/.+$' -and
                $property.Name -notmatch '^\.github/ai-qa/framework/.+$' -and
                $property.Name -notmatch "^\.github/instructions/$namespace" + '[^/]*\.instructions\.md$') {
                throw "Unsafe manifest file: $($property.Name)"
            }
            $previous[$property.Name] = $property.Value
        }
    }
    if ($Verify) {
        if (-not $old) { throw 'AI-QA manifest missing' }
        $problems = @()
        foreach ($name in $previous.Keys) {
            $path = Safe-Path $name
            if (-not (Test-Path -LiteralPath $path -PathType Leaf) -or
                (Hash-Bytes ([System.IO.File]::ReadAllBytes($path))) -ne $previous[$name]) { $problems += $name }
        }
        $existingBlock = Managed-Block $instructionPath
        if ($null -eq $existingBlock -or (Hash-Text $existingBlock) -ne $old.block) {
            $problems += '.github/copilot-instructions.md (managed block)'
        }
        $existingIgnore = Managed-Block $ignorePath $ignoreBegin $ignoreEnd
        if ($null -eq $existingIgnore -or (Hash-Text $existingIgnore) -ne $old.ignore_block) {
            $problems += '.gitignore (managed block)'
        }
        if ($old.framework_version -ne $frameworkVersion) {
            $problems += "framework version (expected $frameworkVersion, found $($old.framework_version))"
        }
        if ($problems.Count) { throw "Verification failed: $($problems -join ', ')" }
        $project = Safe-Path '.github/ai-qa/project/project.md'
        $conventions = Safe-Path '.github/ai-qa/project/conventions'
        if (-not (Test-Path -LiteralPath $project -PathType Leaf) -or
            -not (Test-Path -LiteralPath $conventions -PathType Container)) {
            Write-Output 'WARN: project layer is not configured; run qa-configure'
        }
        Write-Output "Verified AI-QA framework $frameworkVersion, $($previous.Count) files and instruction blocks"
        exit 0
    }
    if ($Uninstall -and -not $old) { throw 'No managed installation to uninstall' }
    if ($Update -and -not $old) { throw 'No managed installation to update' }
    if (-not $Update -and -not $Uninstall -and $old) { throw 'Already installed; use --update or --verify' }
    if ($old -and -not $Uninstall -and $old.prefix -ne $Prefix) {
        throw "Installed prefix is '$($old.prefix)'; use the same --prefix"
    }

    $namespaceCollisions = @()
    foreach ($category in @('agents', 'instructions')) {
        $dir = Join-Path $resolvedTarget ".github/$category"
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        if ((Get-Item -LiteralPath $dir -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Refusing symlink: $dir"
        }
        foreach ($item in (Get-ChildItem -LiteralPath $dir -Force)) {
            $matchesPrefix = if ($category -eq 'agents') {
                $item.Name -like "$Prefix*.agent.md"
            } else { $item.Name -like "$Prefix*.instructions.md" }
            $relative = ".github/$category/$($item.Name)"
            if ($matchesPrefix -and -not $previous.ContainsKey($relative) -and -not $old -and -not $Uninstall) {
                $namespaceCollisions += "$relative (occupied namespace)"
            }
        }
    }
    $skillsDir = Join-Path $resolvedTarget '.github/skills'
    if (Test-Path -LiteralPath $skillsDir) {
        if ((Get-Item -LiteralPath $skillsDir -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Refusing symlink: $skillsDir"
        }
        foreach ($item in (Get-ChildItem -LiteralPath $skillsDir -Force)) {
            if ($item.Name -notlike "$Prefix-*") { continue }
            $relative = ".github/skills/$($item.Name)/"
            if (-not $old -and -not $Uninstall -and -not @($previous.Keys | Where-Object { $_.StartsWith($relative) }).Count) {
                $namespaceCollisions += "$relative (occupied namespace)"
            }
        }
    }
    $files = @{}
    if (-not $Uninstall) {
        $sourceRoot = Join-Path $source '.github'
        if ((Get-Item -LiteralPath $sourceRoot -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Refusing symlink source: $sourceRoot"
        }
        $replacements = [ordered]@{}
        if ($Prefix -ne 'qa') {
            foreach ($agent in (Get-ChildItem -Path (Join-Path $sourceRoot 'agents') -Filter 'qa*.agent.md' -File -ErrorAction SilentlyContinue)) {
                $name = $agent.Name.Substring(0, $agent.Name.Length - '.agent.md'.Length)
                $replacements[$name] = $Prefix + $name.Substring(2)
            }
            foreach ($skill in (Get-ChildItem -Path (Join-Path $sourceRoot 'skills') -Directory -Filter 'qa-*' -ErrorAction SilentlyContinue)) {
                $replacements[$skill.Name] = $Prefix + $skill.Name.Substring(2)
            }
        }
        foreach ($relative in @('agents', 'skills', 'ai-qa/framework', 'instructions')) {
            $dir = Join-Path $sourceRoot $relative
            if (-not (Test-Path -LiteralPath $dir)) { continue }
            $ancestor = $sourceRoot
            foreach ($part in ($relative -split '/')) {
                $ancestor = Join-Path $ancestor $part
                if ((Get-Item -LiteralPath $ancestor -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                    throw "Refusing symlink source: $ancestor"
                }
            }
            foreach ($item in (Get-ChildItem -LiteralPath $dir -File -Recurse)) {
                $tail = $item.FullName.Substring($sourceRoot.Length + 1).Replace('\', '/')
                $include = switch -Regex ($tail) {
                    '^agents/qa[^/]*\.agent\.md$' { $true; break }
                    '^skills/qa-[^/]+/.+' { $true; break }
                    '^ai-qa/framework/.+' { $true; break }
                    '^instructions/qa[^/]*\.instructions\.md$' { $true; break }
                    default { $false }
                }
                if (-not $include) { continue }
                if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "Refusing symlink source: $tail" }
                if ($Prefix -ne 'qa') {
                    if ($tail -match '^agents/') { $tail = $tail -replace '^agents/qa', "agents/$Prefix" }
                    elseif ($tail -match '^skills/') { $tail = $tail -replace '^skills/qa', "skills/$Prefix" }
                    elseif ($tail -match '^instructions/') { $tail = $tail -replace '^instructions/qa', "instructions/$Prefix" }
                }
                $data = [System.IO.File]::ReadAllBytes($item.FullName)
                if ($Prefix -ne 'qa' -and $item.Extension -in @('.md', '.txt', '.json', '.yaml', '.yml')) {
                    $text = $encoding.GetString($data)
                    foreach ($name in ($replacements.Keys | Sort-Object Length -Descending)) {
                        $pattern = '(?<![A-Za-z0-9_-])' + [regex]::Escape($name) + '(?![A-Za-z0-9_-])'
                        $text = [regex]::Replace($text, $pattern, $replacements[$name])
                    }
                    $data = $encoding.GetBytes($text)
                }
                $files[".github/$tail"] = $data
            }
        }
        if ($files.Count -eq 0) { throw 'No framework-owned files found next to installer' }
    }
    $writes = @{}
    $deletes = @()
    $conflicts = @($namespaceCollisions)
    $modified = @()
    $retained = @{}
    $names = @($previous.Keys) + @($files.Keys) | Sort-Object -Unique
    foreach ($name in $names) {
        $path = Safe-Path $name
        $exists = Test-Path -LiteralPath $path
        $current = if ($exists -and (Test-Path -LiteralPath $path -PathType Leaf)) {
            [System.IO.File]::ReadAllBytes($path)
        } else { $null }
        $owned = $previous.ContainsKey($name)
        $clean = $owned -and $null -ne $current -and (Hash-Bytes $current) -eq $previous[$name]
        if ($files.ContainsKey($name)) {
            $desired = $files[$name]
            if ($owned) {
                if ($null -ne $current -and (Hash-Bytes $current) -eq (Hash-Bytes $desired)) { continue }
                if ($clean) { $writes[$path] = $desired }
                else {
                    $modified += $name
                    $retained[$name] = $previous[$name]
                    $writes[(Safe-Path ($name + '.ai-qa-new'))] = $desired
                }
            } elseif ($exists) { $conflicts += $name } else { $writes[$path] = $desired }
        } elseif ($exists) {
            if ($clean -or ($Uninstall -and $Purge)) { $deletes += $path }
            else {
                $modified += $name
                if (-not $Uninstall) { $retained[$name] = $previous[$name] }
            }
        }
    }
    $blocks = @(
        @{ path = $instructionPath; relative = '.github/copilot-instructions.md'; desired = $block; key = 'block'; begin = $begin; end = $end },
        @{ path = $ignorePath; relative = '.gitignore'; desired = $ignoreBlock; key = 'ignore_block'; begin = $ignoreBegin; end = $ignoreEnd }
    )
    $blockActions = @()
    $hashes = @{}
    foreach ($entry in $blocks) {
        $existingBlock = Managed-Block $entry.path $entry.begin $entry.end
        if ($old -and ($null -eq $existingBlock -or (Hash-Text $existingBlock) -ne $old.($entry.key))) {
            $modified += "$($entry.relative) (managed block)"
            if (-not $Uninstall) {
                $hashes[$entry.key] = $old.($entry.key)
                $writes[(Safe-Path ($entry.relative + '.ai-qa-new'))] = $encoding.GetBytes($entry.desired + "`n")
            }
            continue
        }
        if (-not $old -and $null -ne $existingBlock) {
            $conflicts += "$($entry.relative) (existing markers)"
            continue
        }
        $text = if (Test-Path -LiteralPath $entry.path) { Read-Text $entry.path } else { '' }
        if ($null -ne $existingBlock) { $text = $text.Replace($existingBlock, '').Trim("`n") }
        if (-not $Uninstall) {
            $text = $text.TrimEnd("`n") + $(if ($text.Trim()) { "`n`n" } else { '' }) + $entry.desired + "`n"
            $hashes[$entry.key] = Hash-Text $entry.desired
        } elseif ($text) { $text += "`n" }
        $blockActions += @{ path = $entry.path; text = $text }
    }
    if ($conflicts.Count) { throw "Conflicting or modified files (left untouched): $($conflicts -join ', ')" }
    foreach ($path in $writes.Keys) {
        if ($path.EndsWith('.ai-qa-new') -and (Test-Path -LiteralPath $path) -and
            (Hash-Bytes ([System.IO.File]::ReadAllBytes($path))) -ne (Hash-Bytes $writes[$path])) {
            throw "Refusing to overwrite existing review copy: $path"
        }
    }
    if ($DryRun) {
        foreach ($path in $writes.Keys) { Write-Output "[dry-run] write $path" }
        foreach ($path in $deletes) { Write-Output "[dry-run] remove $path" }
        foreach ($entry in $blockActions) { Write-Output "[dry-run] update managed block in $($entry.path)" }
        foreach ($name in $modified) { Write-Output "[dry-run] preserve modified $name" }
        if ($Purge) {
            Write-Output '[dry-run] remove project data and baselines under .github/ai-qa/project, .github/ai-qa/baselines and qa-work'
        }
        Write-Output "[dry-run] update manifest"
        exit 0
    }
    foreach ($path in $deletes) { Remove-Item -LiteralPath $path -Force }
    foreach ($path in $writes.Keys) {
        $null = New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force
        [System.IO.File]::WriteAllBytes($path, $writes[$path])
    }
    foreach ($entry in $blockActions) {
        if ($entry.text) {
            $null = New-Item -ItemType Directory -Path (Split-Path -Parent $entry.path) -Force
            Write-Text $entry.path $entry.text
        } elseif (Test-Path -LiteralPath $entry.path) { Remove-Item -LiteralPath $entry.path -Force }
    }
    if ($Uninstall) {
        Remove-Item -LiteralPath $manifestPath
        if ($Purge) {
            foreach ($path in @((Safe-Path '.github/ai-qa/project'),
                                (Safe-Path '.github/ai-qa/baselines'),
                                (Join-Path $resolvedTarget 'qa-work'))) {
                if (Test-Path -LiteralPath $path) {
                    $item = Get-Item -LiteralPath $path -Force
                    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "Refusing symlink: $path" }
                    Remove-Item -LiteralPath $path -Recurse -Force
                }
            }
        }
        foreach ($path in ($deletes + @($manifestPath))) {
            $dir = Split-Path -Parent $path
            while ($dir -ne $resolvedTarget -and (Test-Path -LiteralPath $dir)) {
                if (@(Get-ChildItem -LiteralPath $dir -Force).Count -ne 0) { break }
                Remove-Item -LiteralPath $dir -Force
                $dir = Split-Path -Parent $dir
            }
        }
        Write-Output 'Uninstalled AI-QA framework assets'
    } else {
        $hashes = [ordered]@{}
        foreach ($name in ($files.Keys | Sort-Object)) {
            $hashes[$name] = if ($retained.ContainsKey($name)) { $retained[$name] } else { Hash-Bytes $files[$name] }
        }
        foreach ($name in $retained.Keys) { $hashes[$name] = $retained[$name] }
        $manifest = [ordered]@{ version = 1; prefix = $Prefix; framework_version = $frameworkVersion;
                                files = $hashes; block = $null; ignore_block = $null }
        $manifest.block = if ($null -ne $old -and -not $blockActions.Where({ $_.path -eq $instructionPath }).Count) { $old.block } else { Hash-Text $block }
        $manifest.ignore_block = if ($null -ne $old -and -not $blockActions.Where({ $_.path -eq $ignorePath }).Count) { $old.ignore_block } else { Hash-Text $ignoreBlock }
        $null = New-Item -ItemType Directory -Path (Split-Path -Parent $manifestPath) -Force
        Write-Text $manifestPath (($manifest | ConvertTo-Json -Depth 8) + "`n")
        foreach ($name in $modified) { Write-Output "Preserved modified $name; review .ai-qa-new if present" }
        Write-Output "$($(if ($Update) { 'Updated' } else { 'Installed' })) $($files.Count) AI-QA framework files"
        if ($Update) {
            $changelog = Join-Path $source 'CHANGELOG.md'
            if (Test-Path -LiteralPath $changelog -PathType Leaf) {
                Write-Output "`nCHANGELOG.md:`n$((Read-Text $changelog).TrimEnd())"
            }
            Write-Output "`nReview .ai-qa-new copies and run qa-configure refresh after reviewing framework changes."
        }
    }
} catch {
    [Console]::Error.WriteLine("Error: $($_.Exception.Message)")
    exit 1
}
