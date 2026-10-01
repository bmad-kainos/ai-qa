#!/usr/bin/env bash
set -euo pipefail

# Keep the implementation local to this file so it can be copied with a checkout.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
export AI_QA_INSTALL_SOURCE="$SCRIPT_DIR"
exec python3 - "$@" <<'PY'
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sys

BEGIN = "<!-- ai-qa:start -->"
END = "<!-- ai-qa:end -->"
BLOCK = BEGIN + "\nAI-QA agents: `.github/agents/qa.agent.md` and `.github/agents/qa-configure.agent.md`.\n" + END
IGNORE_BEGIN = "# ai-qa:start"
IGNORE_END = "# ai-qa:end"
IGNORE_BLOCK = "\n".join((IGNORE_BEGIN, "qa-work/**", "!qa-work/*/", "!qa-work/*/index.md",
                          "!qa-work/*/outputs/", "!qa-work/*/outputs/**", IGNORE_END))
FRAMEWORK_VERSION = "1.0.0"
MANIFEST = Path(".github/ai-qa/manifest.json")
INSTRUCTIONS = Path(".github/copilot-instructions.md")
GITIGNORE = Path(".gitignore")


def digest(data):
    return hashlib.sha256(data).hexdigest()


def fail(message):
    raise ValueError(message)


def source_files(source, prefix):
    root = source / ".github"
    if root.is_symlink():
        fail(f"Refusing symlink source: {root}")
    found = {}
    for pattern in ("agents/qa*.agent.md", "skills/qa-*/**/*", "ai-qa/framework/**/*",
                    "instructions/qa*.instructions.md"):
        for path in root.glob(pattern):
            if path.is_file():
                relative = path.relative_to(source)
                if any((source / Path(*relative.parts[:index])).is_symlink()
                       for index in range(1, len(relative.parts) + 1)):
                    fail(f"Refusing symlink source: {relative}")
                found[str(relative)] = path.read_bytes()
    # The prefix is a namespace for the installed assets, not the target path.
    if prefix != "qa":
        names = {Path(name).name.removesuffix(".agent.md") for name in found
                 if name.startswith(".github/agents/")}
        names.update(Path(name).parts[2] for name in found if name.startswith(".github/skills/"))
        replacements = {name: prefix + name[2:] for name in names}
        symbol = re.compile(r"(?<![A-Za-z0-9_-])(" +
                            "|".join(re.escape(name) for name in sorted(names, key=len, reverse=True)) +
                            r")(?![A-Za-z0-9_-])")
        renamed = {}
        for name, data in found.items():
            parts = list(Path(name).parts)
            if parts[1] == "agents":
                parts[-1] = prefix + parts[-1][2:]
            elif parts[1] == "skills":
                parts[2] = prefix + parts[2][2:]
            elif parts[1] == "instructions":
                parts[-1] = prefix + parts[-1][2:]
            if Path(name).suffix.lower() in (".md", ".txt", ".json", ".yaml", ".yml"):
                text = data.decode("utf-8")
                data = symbol.sub(lambda match: replacements[match.group()], text).encode()
            renamed[str(Path(*parts))] = data
        found = renamed
    if not found:
        fail("No framework-owned files found next to installer")
    return dict(sorted(found.items()))


def read_manifest(path):
    if not path.exists():
        return None
    if path.is_symlink():
        fail(f"Refusing symlink manifest: {path}")
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
        if manifest["version"] != 1 or not isinstance(manifest["files"], dict):
            raise ValueError("invalid manifest schema")
        prefix = manifest.get("prefix")
        if not isinstance(prefix, str) or not re.fullmatch(r"[A-Za-z0-9_-]+", prefix):
            raise ValueError("invalid prefix")
        for key in ("block", "ignore_block"):
            value = manifest.get(key)
            if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{64}", value):
                raise ValueError(f"invalid {key} checksum")
        for name, checksum in manifest["files"].items():
            relative = Path(name)
            if (relative.is_absolute() or ".." in relative.parts
                    or not name.startswith(".github/") or not isinstance(checksum, str)
                    or not re.fullmatch(r"[0-9a-f]{64}", checksum)
                    or not (re.fullmatch(r"\.github/agents/" + re.escape(prefix) + r"[^/]*\.agent\.md", name)
                            or re.fullmatch(r"\.github/skills/" + re.escape(prefix) + r"-[^/]+/.+", name)
                            or name.startswith(".github/ai-qa/framework/")
                            or re.fullmatch(r"\.github/instructions/" + re.escape(prefix) + r"[^/]*\.instructions\.md", name))):
                raise ValueError("unsafe manifest file")
        return manifest
    except (KeyError, ValueError, TypeError) as error:
        fail(f"Invalid install manifest {path}: {error}")


def safe_path(target, relative):
    if relative != GITIGNORE and (relative.is_absolute() or ".." in relative.parts
                                  or relative.parts[0] != ".github"):
        fail(f"Unsafe path: {relative}")
    current = target
    for part in relative.parts:
        current = current / part
        if current.is_symlink():
            fail(f"Refusing symlink: {current}")
    return current


def get_block(path, begin=BEGIN, end=END):
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8")
    if text.count(begin) != text.count(end) or text.count(begin) > 1:
        fail(f"Invalid AI-QA markers in {path}")
    if begin not in text:
        return None
    start = text.index(begin)
    finish = text.index(end, start) + len(end)
    return text[start:finish]


def main():
    parser = argparse.ArgumentParser(description="Install, update, verify or uninstall AI-QA framework assets.")
    parser.add_argument("command", nargs="?", default="install", help="install, update, verify or uninstall")
    parser.add_argument("target", nargs="?", default=".", help="Target repository (default: current directory)")
    parser.add_argument("--prefix", default="qa", help="Framework asset namespace (default: qa)")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--update", action="store_true", help="Update a managed installation")
    parser.add_argument("--uninstall", action="store_true", help="Remove a managed installation")
    parser.add_argument("--purge", action="store_true", help="With --uninstall, also remove modified managed files")
    parser.add_argument("--yes", action="store_true", help="Confirm permanent deletion of project data with --purge")
    parser.add_argument("--verify", action="store_true", help="Check manifest and installed hashes")
    args = parser.parse_intermixed_args()
    if args.command in ("install", "update", "verify", "uninstall", "purge"):
        args.update |= args.command == "update"
        args.verify |= args.command == "verify"
        args.uninstall |= args.command in ("uninstall", "purge")
        args.purge |= args.command == "purge"
    elif args.target == ".":
        args.target = args.command
    else:
        fail(f"Unknown command: {args.command}")
    if not args.prefix or not args.prefix.replace("-", "").replace("_", "").isalnum():
        fail("Prefix must contain only letters, digits, underscores and hyphens")
    if args.purge and not args.uninstall:
        fail("--purge requires --uninstall")
    if args.purge and not args.yes and not args.dry_run:
        fail("--purge deletes project data and baselines; rerun with --yes to confirm")
    if sum((args.update, args.uninstall, args.verify)) > 1:
        fail("--update, --uninstall and --verify are mutually exclusive")
    source = Path(os.environ["AI_QA_INSTALL_SOURCE"]).resolve()
    target = Path(args.target).resolve()
    if not target.is_dir():
        fail(f"Target is not a directory: {target}")
    if target == source and not args.verify:
        fail("Refusing to modify the AI-QA source repository itself")
    manifest_path = safe_path(target, MANIFEST)
    old = read_manifest(manifest_path)
    if args.verify:
        if old is None:
            fail("AI-QA manifest missing")
        problems = []
        for name, checksum in old["files"].items():
            path = safe_path(target, Path(name))
            if not path.is_file() or digest(path.read_bytes()) != checksum:
                problems.append(name)
        instructions = safe_path(target, INSTRUCTIONS)
        block = get_block(instructions)
        if block is None or digest(block.encode()) != old.get("block"):
            problems.append(str(INSTRUCTIONS) + " (managed block)")
        if old.get("framework_version") != FRAMEWORK_VERSION:
            problems.append(f"framework version (expected {FRAMEWORK_VERSION}, found {old.get('framework_version')})")
        ignore = get_block(safe_path(target, GITIGNORE), IGNORE_BEGIN, IGNORE_END)
        if ignore is None or digest(ignore.encode()) != old.get("ignore_block"):
            problems.append(str(GITIGNORE) + " (managed block)")
        if problems:
            fail("Verification failed: " + ", ".join(problems))
        project = target / ".github/ai-qa/project"
        if not (project / "project.md").is_file() or not (project / "conventions").is_dir():
            print("WARN: project layer is not configured; run qa-configure")
        print(f"Verified AI-QA framework {FRAMEWORK_VERSION}, {len(old['files'])} files and instruction blocks")
        return
    if args.uninstall and old is None:
        fail("No managed installation to uninstall")
    if args.update and old is None:
        fail("No managed installation to update")
    if not args.update and not args.uninstall and old is not None:
        fail("Already installed; use --update or --verify")

    files = {} if args.uninstall else source_files(source, args.prefix)
    if old and not args.uninstall and old.get("prefix") != args.prefix:
        fail(f"Installed prefix is {old.get('prefix')!r}; use the same --prefix")
    previous = old["files"] if old else {}
    conflicts = []
    github = target / ".github"
    for directory, pattern in ((github / "agents", args.prefix + "*.agent.md"),
                               (github / "instructions", args.prefix + "*.instructions.md")):
        if directory.is_symlink():
            fail(f"Refusing symlink: {directory}")
        if directory.is_dir():
            for path in directory.glob(pattern):
                name = str(path.relative_to(target))
                if name not in previous and old is None and not args.uninstall:
                    conflicts.append(name + " (occupied namespace)")
    skill_dir = github / "skills"
    if skill_dir.is_symlink():
        fail(f"Refusing symlink: {skill_dir}")
    if skill_dir.is_dir() and old is None and not args.uninstall:
        for path in skill_dir.glob(args.prefix + "-*"):
            name = str(path.relative_to(target)) + "/"
            if not any(owned.startswith(name) for owned in previous):
                conflicts.append(name + " (occupied namespace)")
    modified = []
    writes, deletes = {}, []
    retained = {}
    for name in sorted(set(previous) | set(files)):
        path = safe_path(target, Path(name))
        exists = path.exists()
        current = path.read_bytes() if path.is_file() else None
        owned = name in previous
        clean = owned and current is not None and digest(current) == previous[name]
        if name in files:
            desired = files[name]
            if owned:
                if current == desired:
                    continue
                if not clean:
                    modified.append(name)
                    retained[name] = previous[name]
                    writes[safe_path(target, Path(name + ".ai-qa-new"))] = desired
                else:
                    writes[path] = desired
            elif exists:
                conflicts.append(name)
            else:
                writes[path] = desired
        elif exists:
            if clean or (args.uninstall and args.purge):
                deletes.append(path)
            else:
                modified.append(name)
                if not args.uninstall:
                    retained[name] = previous[name]
    instruction_block = BLOCK.replace(".github/agents/qa", f".github/agents/{args.prefix}")
    blocks = ((INSTRUCTIONS, instruction_block, "block", BEGIN, END),
              (GITIGNORE, IGNORE_BLOCK, "ignore_block", IGNORE_BEGIN, IGNORE_END))
    block_actions = []
    hashes = {}
    for relative, desired, key, begin, end in blocks:
        path = safe_path(target, relative)
        current = get_block(path, begin, end)
        if old:
            if current is None or digest(current.encode()) != old.get(key):
                modified.append(str(relative) + " (managed block)")
                if not args.uninstall:
                    hashes[key] = old.get(key)
                    writes[safe_path(target, Path(str(relative) + ".ai-qa-new"))] = (desired + "\n").encode()
                continue
        elif current is not None:
            conflicts.append(str(relative) + " (existing markers)")
            continue
        text = path.read_text(encoding="utf-8") if path.exists() else ""
        if current is not None:
            text = text.replace(current, "", 1).strip("\n")
        if not args.uninstall:
            text = text.rstrip("\n") + ("\n\n" if text.strip() else "") + desired + "\n"
            hashes[key] = digest(desired.encode())
        elif text:
            text += "\n"
        block_actions.append((path, text))
    if conflicts:
        fail("Conflicting or modified files (left untouched): " + ", ".join(conflicts))
    for path, data in writes.items():
        if path.name.endswith(".ai-qa-new") and path.exists() and path.read_bytes() != data:
            fail(f"Refusing to overwrite existing review copy: {path}")

    if args.dry_run:
        for path in writes:
            print(f"[dry-run] write {path}")
        for path in deletes:
            print(f"[dry-run] remove {path}")
        for path, _ in block_actions:
            print(f"[dry-run] update managed block in {path}")
        for name in modified:
            print(f"[dry-run] preserve modified {name}")
        if args.purge:
            print("[dry-run] remove project data and baselines under .github/ai-qa/project, .github/ai-qa/baselines and qa-work")
        print(f"[dry-run] {'remove' if args.uninstall else 'write'} {manifest_path}")
        return
    for path in deletes:
        path.unlink()
    for path, data in writes.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    for path, text in block_actions:
        if text:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
        elif path.exists():
            path.unlink()
    if args.uninstall:
        manifest_path.unlink()
        if args.purge:
            for relative in (Path(".github/ai-qa/project"), Path(".github/ai-qa/baselines"),
                             Path("qa-work")):
                path = safe_path(target, relative) if relative.parts[0] == ".github" else target / relative
                if path.is_symlink():
                    fail(f"Refusing symlink: {path}")
                if path.is_dir():
                    shutil.rmtree(path)
        for path in deletes + [manifest_path]:
            parent = path.parent
            while parent != target and parent.is_dir():
                try:
                    parent.rmdir()
                except OSError:
                    break
                parent = parent.parent
        print("Uninstalled AI-QA framework assets")
    else:
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(json.dumps({"version": 1, "prefix": args.prefix,
                                             "framework_version": FRAMEWORK_VERSION,
                                             "files": {name: retained.get(name, digest(data)) for name, data in files.items()} | retained,
                                             **hashes},
                                            indent=2) + "\n", encoding="utf-8")
        for name in modified:
            print(f"Preserved modified {name}; review .ai-qa-new if present")
        print(f"{'Updated' if args.update else 'Installed'} {len(files)} AI-QA framework files")
        if args.update:
            changelog = source / "CHANGELOG.md"
            if changelog.is_file():
                print("\nCHANGELOG.md:\n" + changelog.read_text(encoding="utf-8").rstrip())
            print("\nReview .ai-qa-new copies and run qa-configure refresh after reviewing framework changes.")


try:
    main()
except (OSError, UnicodeError, ValueError) as error:
    print(f"Error: {error}", file=sys.stderr)
    sys.exit(1)
PY
