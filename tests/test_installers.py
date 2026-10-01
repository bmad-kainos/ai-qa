"""Installer contract tests using isolated repositories inside this checkout."""

import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class InstallersTest(unittest.TestCase):
    def setUp(self):
        self.sandbox = tempfile.TemporaryDirectory(prefix=".installer-", dir=ROOT / "tests")
        self.addCleanup(self.sandbox.cleanup)
        base = Path(self.sandbox.name)
        self.source = base / "source"
        self.target = base / "target"
        self.source.mkdir()
        self.target.mkdir()
        for name in ("install.sh", "install.ps1"):
            shutil.copyfile(ROOT / name, self.source / name)
        self.write_source(".github/agents/qa-review.agent.md", "agent v1\n")
        self.write_source(".github/agents/unrelated.agent.md", "not owned\n")
        self.write_source(".github/skills/qa-plan/SKILL.md", "skill v1\n")
        self.write_source(".github/skills/unrelated/SKILL.md", "not owned\n")
        self.write_source(".github/ai-qa/framework/rules.md", "rules v1\n")
        self.write_source(".github/ai-qa/project/project.md", "not owned\n")
        self.write_source(".github/instructions/qa-policy.instructions.md", "policy v1\n")
        self.write_source(".github/instructions/project.instructions.md", "not owned\n")

    def write_source(self, name, value):
        path = self.source / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value)

    def call(self, runner, *options, ok=True, target=None):
        command = (["bash", str(self.source / "install.sh")] if runner == "sh"
                   else ["pwsh", "-NoProfile", "-File", str(self.source / "install.ps1")])
        proc = subprocess.run(command + list(options) + [str(target or self.target)],
                              capture_output=True, text=True, cwd=ROOT)
        self.assertEqual(proc.returncode == 0, ok, proc.stdout + "\n" + proc.stderr)
        return proc

    def test_lifecycle_and_preservation(self):
        for runner in ("sh", "ps1"):
            with self.subTest(runner=runner):
                with self.recreate():
                    original = self.target / ".github/copilot-instructions.md"
                    original.parent.mkdir(parents=True)
                    original.write_text("Existing project settings\n")
                    self.call(runner, "--dry-run")
                    self.assertFalse((self.target / ".github/ai-qa").exists())
                    self.call(runner, "install")
                    manifest = json.loads((self.target / ".github/ai-qa/manifest.json").read_text())
                    self.assertEqual(len(manifest["files"]), 4)
                    self.assertIn("Existing project settings", original.read_text())
                    self.assertFalse((self.target / ".github/ai-qa/project").exists())
                    self.assertFalse((self.target / ".github/agents/unrelated.agent.md").exists())
                    self.call(runner, "--verify")
                    self.write_source(".github/agents/qa-review.agent.md", "agent v2\n")
                    self.call(runner, "update", "--dry-run")
                    self.assertEqual((self.target / ".github/agents/qa-review.agent.md").read_text(), "agent v1\n")
                    self.call(runner, "update")
                    self.assertEqual((self.target / ".github/agents/qa-review.agent.md").read_text(), "agent v2\n")
                    self.call(runner, "verify")
                    self.call(runner, "uninstall")
                    self.assertEqual(original.read_text(), "Existing project settings\n")
                    self.assertFalse((self.target / ".github/agents/qa-review.agent.md").exists())
                    self.assertFalse((self.target / ".github/ai-qa/manifest.json").exists())

    def test_collision_modified_file_and_review_copy(self):
        for runner in ("sh", "ps1"):
            with self.subTest(runner=runner):
                with self.recreate():
                    collision = self.target / ".github/agents/qa-review.agent.md"
                    collision.parent.mkdir(parents=True)
                    collision.write_text("custom\n")
                    self.call(runner, ok=False)
                    self.assertEqual(collision.read_text(), "custom\n")
                    self.assertFalse((self.target / ".github/ai-qa/manifest.json").exists())
                    collision.unlink()
                    self.call(runner)
                    collision.write_text("modified\n")
                    self.call(runner, "verify", ok=False)
                    self.call(runner, "update")
                    self.assertEqual((self.target / ".github/agents/qa-review.agent.md.ai-qa-new").read_text(), "agent v1\n")
                    self.call(runner, "uninstall")
                    self.assertEqual(collision.read_text(), "modified\n")
                    self.call(runner, "install", ok=False)
                    collision.unlink()
                    self.assertTrue((self.target / ".github/agents/qa-review.agent.md.ai-qa-new").exists())

    def test_prefix_purge_and_manifest_safety(self):
        for runner in ("sh", "ps1"):
            with self.subTest(runner=runner):
                with self.recreate():
                    collision = self.target / ".github/agents/qa-review.agent.md"
                    collision.parent.mkdir(parents=True)
                    collision.write_text("custom\n")
                    self.call(runner, "install", "--prefix", "other")
                    self.assertTrue((self.target / ".github/agents/other-review.agent.md").exists())
                    self.assertIn(".github/agents/other.agent.md",
                                  (self.target / ".github/copilot-instructions.md").read_text())
                    self.assertEqual(collision.read_text(), "custom\n")
                    project = self.target / ".github/ai-qa/project/project.md"
                    project.parent.mkdir(parents=True)
                    project.write_text("project knowledge\n")
                    unrelated = self.target / ".github/workflows/ci.yml"
                    unrelated.parent.mkdir(parents=True)
                    unrelated.write_text("keep workflow\n")
                    self.call(runner, "verify")
                    self.call(runner, "uninstall")
                    self.assertEqual(project.read_text(), "project knowledge\n")
                    self.call(runner, "install", "--prefix", "other")
                    self.call(runner, "purge")
                    self.assertFalse(project.exists())
                    self.assertEqual(collision.read_text(), "custom\n")
                    self.assertEqual(unrelated.read_text(), "keep workflow\n")
                    self.call(runner, "install", "--prefix", "other")
                    manifest_path = self.target / ".github/ai-qa/manifest.json"
                    manifest = json.loads(manifest_path.read_text())
                    manifest["files"][".github/ai-qa/project/project.md"] = "0" * 64
                    manifest_path.write_text(json.dumps(manifest))
                    self.call(runner, "uninstall", ok=False)

    def test_instruction_conflict_and_self_guard(self):
        for runner in ("sh", "ps1"):
            with self.subTest(runner=runner):
                with self.recreate():
                    self.call(runner, target=self.source, ok=False)
                    self.call(runner)
                    instruction = self.target / ".github/copilot-instructions.md"
                    instruction.write_text(instruction.read_text().replace("AI-QA agents:", "Custom agents:"))
                    self.call(runner, "verify", ok=False)
                    self.call(runner, "uninstall")
                    self.assertTrue(instruction.exists())

    def test_cross_platform_manifest_and_unrelated_files(self):
        for installer, other in (("sh", "ps1"), ("ps1", "sh")):
            with self.subTest(installer=installer):
                with self.recreate():
                    self.call(installer)
                    unrelated = self.target / ".github/skills/qa-plan/personal.md"
                    unrelated.write_text("personal data\n")
                    self.call(other, "verify")
                    self.call(other, "update")
                    self.call(installer, "uninstall")
                    self.assertEqual(unrelated.read_text(), "personal data\n")

    def recreate(self):
        """Reset each runner's target and source to the same baseline."""
        class Context:
            def __enter__(inner):
                if self.target.exists():
                    shutil.rmtree(self.target)
                self.target.mkdir()
                self.write_source(".github/agents/qa-review.agent.md", "agent v1\n")
            def __exit__(inner, *exc):
                return False
        return Context()


class FixtureIntegrationTest(unittest.TestCase):
    """Exercise real framework assets against copies of every example project."""

    def test_all_fixture_lifecycles(self):
        self.assertEqual(
            {path.name for path in (ROOT / "examples/fixtures").iterdir() if path.is_dir()},
            {"conflicting", "dotnet", "empty", "java-ado", "python-jira-cloud", "typescript-github"},
        )
        with tempfile.TemporaryDirectory(prefix=".installer-fixtures-", dir=ROOT / "tests") as sandbox:
            for fixture in sorted((ROOT / "examples/fixtures").iterdir()):
                if not fixture.is_dir():
                    continue
                for installer, partner in (("sh", "ps1"), ("ps1", "sh")):
                    with self.subTest(fixture=fixture.name, installer=installer):
                        target = Path(sandbox) / (fixture.name + "-" + installer)
                        shutil.copytree(fixture, target)
                        before = {p.relative_to(target): p.read_bytes()
                                  for p in target.rglob("*") if p.is_file()}

                        def invoke(which, command, success=True):
                            base = (["bash", str(ROOT / "install.sh")] if which == "sh"
                                    else ["pwsh", "-NoProfile", "-File", str(ROOT / "install.ps1")])
                            result = subprocess.run(base + [command, str(target)], cwd=ROOT,
                                                    capture_output=True, text=True)
                            self.assertEqual(result.returncode == 0, success,
                                             f"{fixture.name}/{which}/{command}: {result.stdout}\n{result.stderr}")

                        invoke(installer, "install")
                        invoke(partner, "verify")
                        installed = target / ".github/ai-qa/framework/defaults/project.md"
                        self.assertTrue(installed.exists())
                        installed.write_text("hand-modified framework file\n")
                        invoke(partner, "update")
                        self.assertEqual(installed.read_text(), "hand-modified framework file\n")
                        self.assertTrue((installed.parent / (installed.name + ".ai-qa-new")).exists())
                        invoke(installer, "verify", success=False)
                        if installer == "sh":
                            invoke(partner, "uninstall")
                            self.assertTrue(installed.exists())
                        else:
                            invoke(partner, "purge")
                            self.assertFalse(installed.exists())
                        for relative, contents in before.items():
                            self.assertEqual((target / relative).read_bytes(), contents, str(relative))

    def test_real_source_self_guard(self):
        for runner in (("bash", str(ROOT / "install.sh")),
                       ("pwsh", "-NoProfile", "-File", str(ROOT / "install.ps1"))):
            with self.subTest(runner=runner[0]):
                result = subprocess.run([*runner, "install", str(ROOT)], cwd=ROOT,
                                        capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("source repository", result.stderr)


if __name__ == "__main__":
    unittest.main()
