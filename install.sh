#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' 'Usage: install.sh [install|update|verify|uninstall] [target] [options]' \
    '  --dry-run       Print planned changes without modifying the target.' \
    '  --prefix NAME   Rename qa agents and skills into NAME namespace.' \
    '  --purge         With uninstall, remove project data and qa-work after confirmation.' \
    '  --yes           Confirm --purge without prompting.' \
    '  -h, --help      Show this help.'
}
fail() { printf 'Error: %s\n' "$1" >&2; exit 1; }
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE="$SCRIPT_DIR/.github"
[[ -f "$SCRIPT_DIR/VERSION" ]] || fail 'Missing VERSION next to installer'
VERSION="$(sed -n '1{s/[[:space:]]//g;p;}' "$SCRIPT_DIR/VERSION")"
[[ -n "$VERSION" ]] || fail 'VERSION is empty'
COMMAND=install TARGET=. PREFIX=qa PREFIX_SET=0 DRY=0 PURGE=0 YES=0 COMMAND_SET=0
while (($#)); do
  case "$1" in
    install|update|verify|uninstall) ((COMMAND_SET == 0)) || fail 'Only one command may be specified'; COMMAND="$1"; COMMAND_SET=1 ;;
    --dry-run) DRY=1 ;;
    --prefix) shift; (($#)) || fail '--prefix requires a value'; PREFIX="$1"; PREFIX_SET=1 ;;
    --purge) PURGE=1 ;;
    --yes) YES=1 ;;
    -h|--help) usage; exit 0 ;;
    --*) fail "Unknown option: $1" ;;
    *) [[ "$TARGET" == . ]] || fail 'Only one target may be specified'; TARGET="$1" ;;
  esac
  shift
done
[[ "$PREFIX" =~ ^[A-Za-z0-9_-]+$ ]] || fail 'Prefix must contain only letters, digits, underscores and hyphens'
if ((PURGE)) && [[ "$COMMAND" != uninstall ]]; then fail '--purge requires uninstall'; fi
[[ -d "$TARGET" ]] || fail "Target is not a directory: $TARGET"
[[ ! -L "$TARGET" ]] || fail "Refusing symlink target: $TARGET"
TARGET="$(cd "$TARGET" && pwd -P)"
if [[ "$COMMAND" != verify && ( "$TARGET" == "$SCRIPT_DIR" || ( -f "$TARGET/install.sh" && -d "$TARGET/.github/ai-qa/framework" ) ) ]]; then fail 'Refusing to modify the AI-QA source repository itself'; fi
[[ -d "$SOURCE" ]] || fail 'Missing .github framework folder next to installer'

hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else fail 'Neither sha256sum nor shasum is available'
  fi
}
tmp="$(mktemp -d "${TMPDIR:-/tmp}/ai-qa-install.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
MANIFEST_REL=.github/ai-qa/manifest.json
MANIFEST="$TARGET/$MANIFEST_REL"
safe_rel() {
  local rel="$1" item cur="$TARGET" saved="$IFS"
  [[ "$rel" != /* && "$rel" != *'..'* && "$rel" != *'|'* && "$rel" != *'"'* ]] || fail "Unsafe manifest path: $rel"
  case "$rel" in
    .github/agents/*|.github/skills/*|.github/ai-qa/framework/*|.github/ai-qa/manifest.json|.github/copilot-instructions.md|.gitignore|.github/ai-qa/project|.github/ai-qa/project/*|.github/ai-qa/baselines|.github/ai-qa/baselines/*|qa-work|qa-work/*) ;;
    *) fail "Unsafe path: $rel" ;;
  esac
  IFS=/; for item in $rel; do cur="$cur/$item"; [[ ! -L "$cur" ]] || fail "Refusing symlink: $cur"; done; IFS="$saved"
}
assert_no_links() {
  local tree="$1" found
  [[ ! -L "$tree" ]] || fail "Refusing symlink: $tree"
  if [[ -d "$tree" ]]; then found="$(find "$tree" -type l -print)"; [[ -z "$found" ]] || fail "Refusing symlink in managed path: $(printf '%s\n' "$found" | sed -n '1p')"; fi
}
meta() { awk -v k="$1" 'index($0, "\"" k "\"") { sub(/^.*: "/, ""); sub(/".*$/, ""); print; exit }' "${MANIFEST_SRC:-$MANIFEST}"; }
ver_gt() { awk -v a="$1" -v b="$2" 'BEGIN{n=split(a,x,".");m=split(b,y,".");l=(n>m?n:m);for(i=1;i<=l;i++){if(x[i]+0>y[i]+0)exit 0;if(x[i]+0<y[i]+0)exit 1}exit 1}'; }
extract() { [[ -f "$1" ]] || return 1; awk -v b="$2" -v e="$3" '$0==b{inside=1;n++} inside{print} $0==e&&inside{inside=0} END{if(n!=1||inside)exit 1}' "$1"; }
markers_ok() { [[ ! -f "$1" ]] && return 0; awk -v b="$2" -v e="$3" '$0==b{a++}$0==e{z++}END{exit !(a==z&&a<=1)}' "$1"; }
merge_block() {
  local file="$1" begin="$2" end="$3" block="$4" out="$5" remove="$6"
  if [[ -f "$file" ]]; then
    # On removal, drop the blank separator line the installer added before the block.
    awk -v b="$begin" -v e="$end" -v r="$block" -v del="$remove" '
      held&&$0!=b{print "";held=0}
      $0==b{held=0;if(!done){if(del==0)while((getline line<r)>0)print line;close(r);done=1}skip=1;next}
      skip&&$0==e{skip=0;next}
      !skip&&del==1&&$0==""{held=1;next}
      !skip{print}
    END{if(held)print "";if(!done&&del==0){if(NR)print "";while((getline line<r)>0)print line;close(r)}}
    ' "$file" > "$out"
    if [[ "$remove" == 1 && "$7" == 0 && -s "$out" ]]; then printf '%s' "$(cat "$out")" > "$out.noeol"; mv "$out.noeol" "$out"; fi
  elif [[ "$remove" == 0 ]]; then cp "$block" "$out"; else : > "$out"; fi
}

safe_rel "$MANIFEST_REL"
old_files="$tmp/old-files" old_dirs="$tmp/old-dirs" desired="$tmp/desired"
: > "$old_files"; : > "$old_dirs"; : > "$desired"
OLD_PREFIX= OLD_VERSION= OLD_BLOCK= OLD_IGNORE= OLD_INS_CREATED=0 OLD_GIT_CREATED=0 OLD_INS_EOL=1 OLD_GIT_EOL=1
if [[ -e "$MANIFEST" ]]; then
  [[ -f "$MANIFEST" ]] || fail "Invalid install manifest: $MANIFEST"
  # Normalise to one JSON token per line so hand-edited or single-line manifests parse the same way.
  awk '{ gsub(/[{\[,]/, "&\n"); gsub(/[}\]]/, "\n&\n"); print }' "$MANIFEST" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | grep -v '^$' > "$tmp/manifest-norm" || :
  MANIFEST_SRC="$tmp/manifest-norm"
  OLD_PREFIX="$(meta prefix)"; OLD_VERSION="$(meta framework_version)"; OLD_BLOCK="$(meta instructions_block_sha256)"; OLD_IGNORE="$(meta gitignore_block_sha256)"
  OLD_INS_EOL="$(meta instructions_eol)"; OLD_GIT_EOL="$(meta gitignore_eol)"
  [[ "$OLD_PREFIX" =~ ^[A-Za-z0-9_-]+$ && -n "$OLD_VERSION" ]] || fail 'Invalid install manifest metadata'
  [[ "$OLD_BLOCK" =~ ^[0-9a-f]{64}$ && "$OLD_IGNORE" =~ ^[0-9a-f]{64}$ ]] || fail 'Invalid manifest block hashes'
  section() { awk -v k="\"$1\"" -v op="$2" -v cl="$3" 'index($0, k)==1 && substr($0, length($0))==op {f=1; next} f && $0==cl {exit} f {print}' "$MANIFEST_SRC"; }
  section files '{' '}' > "$tmp/manifest-files"
  while IFS= read -r line; do
    [[ "$line" =~ ^\"([^\"]+)\":[[:space:]]*\"([0-9a-f]{64})\",?$ ]] || fail "Invalid manifest entry: $line"
    printf '%s|%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" >> "$old_files"
  done < "$tmp/manifest-files"
  section created_dirs '[' ']' | sed -E 's/^"([^"]*)",?$/\1/' > "$old_dirs"
  section created_files '[' ']' | sed -E 's/^"([^"]*)",?$/\1/' > "$tmp/created-files"
    grep -Fxq '.github/copilot-instructions.md' "$tmp/created-files" && OLD_INS_CREATED=1 || :
    grep -Fxq '.gitignore' "$tmp/created-files" && OLD_GIT_CREATED=1 || :
  while IFS='|' read -r rel sum; do
    [[ -n "$rel" ]] || continue; [[ "$sum" =~ ^[0-9a-f]{64}$ ]] || fail "Invalid manifest checksum: $rel"; safe_rel "$rel"
    case "$rel" in .github/agents/"$OLD_PREFIX"*.agent.md|.github/skills/"$OLD_PREFIX"-*/*|.github/ai-qa/framework/*) ;; *) fail "Unsafe manifest path: $rel" ;; esac
  done < "$old_files"
fi

if [[ "$COMMAND" == verify ]]; then
  [[ -f "$MANIFEST" ]] || fail 'AI-QA manifest missing'
  problems="$tmp/problems"; : > "$problems"
  while IFS='|' read -r rel sum; do [[ -n "$rel" ]] || continue; path="$TARGET/$rel"; safe_rel "$rel"; [[ -f "$path" && "$(hash_file "$path")" == "$sum" ]] || printf '%s\n' "$rel" >> "$problems"; done < "$old_files"
  instructions="$TARGET/.github/copilot-instructions.md" gitignore="$TARGET/.gitignore"
  markers_ok "$instructions" '<!-- ai-qa:start -->' '<!-- ai-qa:end -->' || printf '%s\n' 'copilot-instructions.md (invalid markers)' >> "$problems"
  markers_ok "$gitignore" '# ai-qa:start' '# ai-qa:end' || printf '%s\n' '.gitignore (invalid markers)' >> "$problems"
  extract "$instructions" '<!-- ai-qa:start -->' '<!-- ai-qa:end -->' > "$tmp/block" 2>/dev/null || :
  extract "$gitignore" '# ai-qa:start' '# ai-qa:end' > "$tmp/ignore" 2>/dev/null || :
  [[ -s "$tmp/block" && "$(hash_file "$tmp/block")" == "$OLD_BLOCK" ]] || printf '%s\n' 'copilot-instructions.md (managed block)' >> "$problems"
  [[ -s "$tmp/ignore" && "$(hash_file "$tmp/ignore")" == "$OLD_IGNORE" ]] || printf '%s\n' '.gitignore (managed block)' >> "$problems"
  [[ ! -s "$problems" ]] || fail "Verification failed: $(awk 'BEGIN{ORS=", "}{print}' "$problems" | sed 's/, $//')"
  [[ "$OLD_VERSION" == "$VERSION" ]] || printf 'WARN: installed framework version %s differs from source %s\n' "$OLD_VERSION" "$VERSION"
  if [[ ! -f "$TARGET/.github/ai-qa/project/project.md" ]]; then printf 'WARN: project layer is not configured; run qa-configure\n'; fi
  printf 'Verified AI-QA framework %s, %s files and instruction blocks\n' "$OLD_VERSION" "$(wc -l < "$old_files" | awk '{print $1}')"; exit 0
fi
if [[ "$COMMAND" == update || "$COMMAND" == uninstall ]]; then [[ -f "$MANIFEST" ]] || fail "No managed installation to $COMMAND"; fi
if [[ "$COMMAND" == install && -f "$MANIFEST" ]]; then fail 'Already installed; use update or verify'; fi
if [[ "$COMMAND" == update && "$PREFIX_SET" == 0 ]]; then PREFIX="$OLD_PREFIX"; fi
if [[ -f "$MANIFEST" && "$COMMAND" != uninstall && "$PREFIX" != "$OLD_PREFIX" ]]; then fail "Installed prefix is '$OLD_PREFIX'; use the same --prefix"; fi
if ((PURGE)) && ((YES == 0)); then
  [[ -t 0 ]] || fail '--purge requires confirmation; use --yes for non-interactive use'
  target_name="$(basename "$TARGET")"; printf 'Purge project data and qa-work from %s? Type %s or yes: ' "$target_name" "$target_name" >&2
  IFS= read -r answer || answer=; [[ "$answer" == "$target_name" || "$answer" == yes ]] || fail 'Purge not confirmed'
fi
if ((PURGE)); then for rel in .github/ai-qa/project .github/ai-qa/baselines qa-work; do assert_no_links "$TARGET/$rel"; done; fi

if [[ "$COMMAND" != uninstall ]]; then
  for dir in agents skills ai-qa/framework; do assert_no_links "$SOURCE/$dir"; done
  find "$SOURCE/agents" -type f -name 'qa*.agent.md' -print 2>/dev/null | while IFS= read -r f; do basename "$f" .agent.md; done > "$tmp/agent-names"
  find "$SOURCE/skills" -mindepth 1 -maxdepth 1 -type d -name 'qa-*' -print 2>/dev/null | sed 's|.*/||' | sort -u > "$tmp/skill-names"
  cat "$tmp/agent-names" "$tmp/skill-names" | sort -u > "$tmp/names"
  for d in agents skills ai-qa/framework; do [[ ! -d "$SOURCE/$d" ]] || find "$SOURCE/$d" -type f -print; done | sort > "$tmp/source-list"
  pruned="$tmp/pruned-packs"; sed -n 's/^[[:space:]]*\([A-Za-z0-9_-][A-Za-z0-9_-]*\)[[:space:]]*$/\1/p' "$TARGET/.github/ai-qa/project/pruned-packs.txt" > "$pruned" 2>/dev/null || :
  while IFS= read -r src; do
    rel="${src#"$SOURCE/"}"; case "$rel" in agents/qa*.agent.md|skills/qa-*/*|ai-qa/framework/*) ;; *) continue ;; esac
    case "$rel" in ai-qa/framework/packs/*/*) pack="${rel#ai-qa/framework/packs/}"; pack="${pack%%/*}"; if [[ "$pack" != _TEMPLATE ]] && grep -Fxq "$pack" "$pruned"; then continue; fi ;; esac
    dest="$rel"
    if [[ "$PREFIX" != qa ]]; then case "$rel" in agents/qa*) dest="agents/${PREFIX}${rel#agents/qa}" ;; skills/qa-*) dest="skills/${PREFIX}-${rel#skills/qa-}" ;; esac; fi
    outrel=".github/$dest"; safe_rel "$outrel"; staged="$tmp/assets/$outrel"; mkdir -p "$(dirname "$staged")"; cp "$src" "$staged"
    case "$src" in *.md|*.txt|*.json|*.yaml|*.yml)
      if [[ "$PREFIX" != qa ]]; then while IFS= read -r name; do [[ -n "$name" ]] || continue; old="$name"; new="$PREFIX${name#qa}"; sed -E "s/(^|[^[:alnum:]_-])${old}([^[:alnum:]_-]|$)/\\1${new}\\2/g" "$staged" > "$tmp/rewrite"; cp "$tmp/rewrite" "$staged"; done < "$tmp/names"; fi ;;
    esac
    printf '%s|%s\n' "$outrel" "$staged" >> "$desired"
  done < "$tmp/source-list"
  [[ -s "$desired" ]] || fail 'No framework-owned files found in .github'
fi

collisions="$tmp/collisions" plan="$tmp/plan" new_files="$tmp/new-files" modified="$tmp/modified"
: > "$collisions"; : > "$plan"; : > "$new_files"; : > "$modified"
if [[ "$COMMAND" != uninstall ]]; then
  for category in agents instructions; do
    [[ "$category" != instructions || "$PREFIX" == qa ]] || continue
    dir="$TARGET/.github/$category"; [[ ! -L "$dir" ]] || fail "Refusing symlink: $dir"; [[ -d "$dir" ]] || continue
    pattern="$PREFIX*.agent.md"; [[ "$category" != instructions ]] || pattern="$PREFIX*.instructions.md"
    for path in "$dir"/$pattern; do [[ -e "$path" ]] || continue; rel="${path#"$TARGET/"}"; awk -F'|' -v p="$rel" '$1==p{f=1}END{exit !f}' "$old_files" || printf '%s (occupied namespace)\n' "$rel" >> "$collisions"; done
  done
  dir="$TARGET/.github/skills"; [[ ! -L "$dir" ]] || fail "Refusing symlink: $dir"
  if [[ -d "$dir" ]]; then for path in "$dir"/"$PREFIX"-*; do [[ -e "$path" ]] || continue; rel="${path#"$TARGET/"}"; awk -F'|' -v p="$rel/" '$1==p||index($1,p)==1{f=1}END{exit !f}' "$old_files" || printf '%s/ (occupied namespace)\n' "$rel" >> "$collisions"; done; fi
fi
while IFS='|' read -r rel staged; do
  [[ -n "$rel" ]] || continue; path="$TARGET/$rel"; safe_rel "$rel"
  old_hash="$(awk -F'|' -v p="$rel" '$1==p{print $2}' "$old_files")"; desired_hash="$(hash_file "$staged")"
  if [[ -n "$old_hash" ]]; then
    if [[ -f "$path" && "$(hash_file "$path")" == "$desired_hash" ]]; then printf '%s|%s\n' "$rel" "$desired_hash" >> "$new_files"
    elif [[ -f "$path" && "$(hash_file "$path")" == "$old_hash" ]]; then printf 'write|%s|%s\n' "$rel" "$staged" >> "$plan"; printf '%s|%s\n' "$rel" "$desired_hash" >> "$new_files"
    else printf '%s\n' "$rel" >> "$modified"; review="$path.ai-qa-new"; [[ ! -e "$review" || "$(hash_file "$review")" == "$desired_hash" ]] || fail "Refusing to overwrite existing review copy: $review"; printf 'write|%s.ai-qa-new|%s\n' "$rel" "$staged" >> "$plan"; printf '%s|%s\n' "$rel" "$old_hash" >> "$new_files"; fi
  elif [[ -e "$path" ]]; then printf '%s\n' "$rel" >> "$collisions"
  else printf 'write|%s|%s\n' "$rel" "$staged" >> "$plan"; printf '%s|%s\n' "$rel" "$desired_hash" >> "$new_files"; fi
done < "$desired"
if [[ "$COMMAND" == update || "$COMMAND" == uninstall ]]; then
  while IFS='|' read -r rel sum; do
    [[ -n "$rel" ]] || continue
    if [[ "$COMMAND" == uninstall ]] || ! awk -F'|' -v p="$rel" '$1==p{f=1}END{exit !f}' "$desired"; then path="$TARGET/$rel"; safe_rel "$rel"; if [[ -f "$path" && "$(hash_file "$path")" == "$sum" ]]; then printf 'remove|%s|\n' "$rel" >> "$plan"; elif [[ -e "$path" ]]; then printf '%s\n' "$rel" >> "$modified"; fi; fi
  done < "$old_files"
fi

begin='<!-- ai-qa:start -->' end='<!-- ai-qa:end -->' ibegin='# ai-qa:start' iend='# ai-qa:end'
pointer="$tmp/pointer" ignore="$tmp/ignore"
printf '%s\n%s\n%s\n%s\n%s\n%s\n' "$begin" "AI-QA agents: @${PREFIX} and @${PREFIX}-configure." 'Framework: .github/ai-qa/framework/.' "Project layer: .github/ai-qa/project/ (written only by ${PREFIX}-configure)." 'Safety: .github/ai-qa/framework/method/safety.md.' "$end" > "$pointer"
printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n' "$ibegin" 'qa-work/**' '!qa-work/*/' '!qa-work/*/index.md' '!qa-work/*/outputs/' '!qa-work/*/outputs/**' "$iend" > "$ignore"
block_hash="$(hash_file "$pointer")" ignore_hash="$(hash_file "$ignore")"
ins_created="$OLD_INS_CREATED" git_created="$OLD_GIT_CREATED" ins_eol="${OLD_INS_EOL:-1}" git_eol="${OLD_GIT_EOL:-1}"
ends_eol() { [[ ! -s "$1" || -z "$(tail -c 1 "$1")" ]] && echo 1 || echo 0; }
if [[ ! -f "$MANIFEST" ]]; then
  [[ -e "$TARGET/.github/copilot-instructions.md" ]] || ins_created=1; [[ -e "$TARGET/.gitignore" ]] || git_created=1
  ins_eol="$(ends_eol "$TARGET/.github/copilot-instructions.md")"; git_eol="$(ends_eol "$TARGET/.gitignore")"
fi
for kind in instructions ignore; do
  if [[ "$kind" == instructions ]]; then rel=.github/copilot-instructions.md; path="$TARGET/$rel"; b="$begin"; e="$end"; block="$pointer"; oldhash="$OLD_BLOCK"; eol="$ins_eol"; else rel=.gitignore; path="$TARGET/$rel"; b="$ibegin"; e="$iend"; block="$ignore"; oldhash="$OLD_IGNORE"; eol="$git_eol"; fi
  safe_rel "$rel"; markers_ok "$path" "$b" "$e" || fail "Invalid AI-QA markers in $path"
  current="$tmp/current-$kind"; extract "$path" "$b" "$e" > "$current" 2>/dev/null || :
  if [[ -f "$MANIFEST" ]]; then
    if [[ ! -s "$current" || "$(hash_file "$current")" != "$oldhash" ]]; then printf '%s (managed block)\n' "$rel" >> "$modified"; [[ "$COMMAND" == uninstall ]] || printf 'write|%s.ai-qa-new|%s\n' "$rel" "$block" >> "$plan"; continue; fi
  elif [[ -s "$current" ]]; then printf '%s (existing markers)\n' "$rel" >> "$collisions"; continue; fi
  merged="$tmp/merged-$kind"; remove=0; [[ "$COMMAND" != uninstall ]] || remove=1; merge_block "$path" "$b" "$e" "$block" "$merged" "$remove" "$eol"
  if [[ "$COMMAND" != uninstall ]]; then printf 'write|%s|%s\n' "$rel" "$merged" >> "$plan"
  elif [[ "$(awk 'NF{f=1}END{print f+0}' "$merged")" == 1 ]]; then printf 'write|%s|%s\n' "$rel" "$merged" >> "$plan"
  elif [[ "$kind" == instructions && "$ins_created" == 1 || "$kind" == ignore && "$git_created" == 1 ]]; then printf 'remove|%s|\n' "$rel" >> "$plan"; fi
done
[[ ! -s "$collisions" ]] || fail "Conflicting or modified files (left untouched): $(awk 'BEGIN{ORS=", "}{print}' "$collisions" | sed 's/, $//')"

created_dirs="$tmp/created-dirs"; : > "$created_dirs"
if [[ "$COMMAND" != uninstall ]]; then
  cat "$old_dirs" > "$created_dirs"
  while IFS='|' read -r action rel staged; do [[ "$action" == write ]] || continue; parent="$(dirname "$rel")"; while [[ "$parent" != . && ! -d "$TARGET/$parent" ]]; do grep -Fxq "$parent" "$created_dirs" || printf '%s\n' "$parent" >> "$created_dirs"; parent="$(dirname "$parent")"; done; done < "$plan"
  parent="$(dirname "$MANIFEST_REL")"; while [[ "$parent" != . && ! -d "$TARGET/$parent" ]]; do grep -Fxq "$parent" "$created_dirs" || printf '%s\n' "$parent" >> "$created_dirs"; parent="$(dirname "$parent")"; done
fi
if [[ "$COMMAND" == uninstall ]]; then printf 'remove|%s|\n' "$MANIFEST_REL" >> "$plan"; if ((PURGE)); then printf 'purge|.github/ai-qa/project|\npurge|.github/ai-qa/baselines|\npurge|qa-work|\n' >> "$plan"; fi; fi
if ((DRY)); then
  while IFS='|' read -r action rel staged; do [[ -n "$action" ]] && printf '[dry-run] %s %s\n' "$action" "$TARGET/$rel"; done < "$plan"
  while IFS= read -r rel; do [[ -n "$rel" ]] && printf '[dry-run] preserve modified %s; review %s.ai-qa-new\n' "$rel" "$TARGET/$rel"; done < "$modified"
  [[ "$COMMAND" == uninstall ]] || printf '[dry-run] write %s\n' "$MANIFEST"
  exit 0
fi
while IFS='|' read -r action rel staged; do
  [[ -n "$action" ]] || continue; path="$TARGET/$rel"
  case "$action" in
    write) safe_rel "$rel"; mkdir -p "$(dirname "$path")"; cp "$staged" "$path" ;;
    remove) safe_rel "$rel"; [[ ! -e "$path" ]] || rm -f "$path" ;;
    purge) safe_rel "$rel"; if [[ -e "$path" ]]; then assert_no_links "$path"; rm -rf "$path"; fi ;;
  esac
done < "$plan"
if [[ "$COMMAND" == uninstall ]]; then
  awk -F/ '{print NF "\t" $0}' "$old_dirs" | sort -rn | cut -f2- | while IFS= read -r rel; do [[ -n "$rel" ]] || continue; path="$TARGET/$rel"; [[ ! -d "$path" ]] || rmdir "$path" 2>/dev/null || :; done
  printf 'Uninstalled AI-QA framework assets\n'; while IFS= read -r rel; do [[ -n "$rel" ]] && printf 'Preserved modified %s\n' "$rel"; done < "$modified"; exit 0
fi

mkdir -p "$(dirname "$MANIFEST")"
{
  printf '{\n  "schema": 1,\n  "framework_version": "%s",\n  "prefix": "%s",\n  "instructions_block_sha256": "%s",\n  "gitignore_block_sha256": "%s",\n  "instructions_eol": "%s",\n  "gitignore_eol": "%s",\n  "created_files": [' "$VERSION" "$PREFIX" "$block_hash" "$ignore_hash" "$ins_eol" "$git_eol"
  sep=''; [[ "$ins_created" != 1 ]] || { printf '".github/copilot-instructions.md"'; sep=,; }
  [[ "$git_created" != 1 ]] || printf '%s".gitignore"' "$sep"
  printf '],\n  "created_dirs": ['
  sep=''; while IFS= read -r rel; do [[ -n "$rel" ]] || continue; printf '%s\n    "%s"' "$sep" "$rel"; sep=,; done < "$created_dirs"
  printf '\n  ],\n  "files": {\n'
  first=1; while IFS='|' read -r rel sum; do [[ -n "$rel" ]] || continue; [[ $first == 1 ]] || printf ',\n'; printf '    "%s": "%s"' "$rel" "$sum"; first=0; done < "$new_files"
  printf '\n  }\n}\n'
} > "$tmp/manifest"
cp "$tmp/manifest" "$MANIFEST"
while IFS= read -r rel; do [[ -n "$rel" ]] && printf 'Preserved modified %s; review .ai-qa-new if present\n' "$rel"; done < "$modified"
if [[ "$COMMAND" == update ]]; then
  printf 'Updated %s AI-QA framework files\n' "$(wc -l < "$new_files" | awk '{print $1}')"
  needs_refresh=0
  while IFS= read -r v; do
    [[ -n "$v" ]] || continue
    if ver_gt "$v" "$OLD_VERSION" && ! ver_gt "$v" "$VERSION"; then needs_refresh=1; fi
  done < <(sed -n 's/^[[:space:]]*refresh-required:[[:space:]]*\([0-9.]*\).*/\1/p' "$SCRIPT_DIR/docs/migrations.md" 2>/dev/null)
  ((needs_refresh == 0)) || printf '\nThis update requires qa-configure refresh (see docs/migrations.md).\n'
else printf 'Installed %s AI-QA framework files\n' "$(wc -l < "$new_files" | awk '{print $1}')"; fi
