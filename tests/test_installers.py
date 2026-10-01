"""Lifecycle tests for both AI-QA installers."""

import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def runners():
    available = [("sh", ["bash"])]
    if shutil.which("pwsh"):
        available.append(("ps1", ["pwsh", "-NoProfile"]))
    return available


class SyntheticInstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="ai-qa-install-tests-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.source = self.base / "source"
        self.target = self.base / "target"
        self.target.mkdir()
        self.build_source()

    def build_source(self):
        self.source.mkdir()
        shutil.copy2(ROOT / "install.sh", self.source / "install.sh")
        shutil.copy2(ROOT / "install.ps1", self.source / "install.ps1")
        (self.source / "VERSION").write_text("1.0.0\n")
        (self.source / "docs").mkdir()
        (self.source / "docs/migrations.md").write_text("# Migrations\n\nrefresh-required: 1.0.0\n")
        self.framework_file("agents/qa.agent.md", "Agent uses qa-plan and qa-configure.\n")
        self.framework_file("agents/qa-configure.agent.md", "Configure.\n")
        self.framework_file("skills/qa-plan/SKILL.md", "See qa.agent.md.\n")
        self.framework_file("skills/qa-plan/references/check.md", "Reference v1.\n")
        self.framework_file("ai-qa/framework/method/rules.md", "Framework v1.\n")
        self.framework_file("ai-qa/framework/method/retired.md", "Removed next version.\n")
        self.framework_file("instructions/qa-rendered.instructions.md", "Configure-owned, never installed.\n")

    def framework_file(self, relative, text):
        path = self.source / ".github" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def call(self, runner, *arguments, target=None, expected=0, input_text=None):
        name, base = runner
        installer = self.source / ("install.sh" if name == "sh" else "install.ps1")
        command = base + ([str(installer)] if name == "sh" else ["-File", str(installer)])
        mapping = {"--dry-run": "-DryRun", "--purge": "-Purge", "--yes": "-Yes", "--prefix": "-Prefix"}
        command.extend(mapping.get(str(item), str(item)) if name == "ps1" else str(item) for item in arguments)
        command.append(str(target or self.target))
        result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, input=input_text or "")
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result

    def fresh(self, runner):
        """Give each runner its own source and target so subtests are independent."""
        shutil.rmtree(self.source, ignore_errors=True)
        shutil.rmtree(self.target, ignore_errors=True)
        self.target.mkdir()
        self.build_source()

    def test_install_update_verify_uninstall_preserves_project_files(self):
        for runner in runners():
            self.fresh(runner)
            with self.subTest(runner=runner[0]):
                (self.target / "README.md").write_text("project readme\n")
                (self.target / ".github/workflows").mkdir(parents=True)
                (self.target / ".github/workflows/ci.yml").write_text("project workflow\n")
                instructions = self.target / ".github/copilot-instructions.md"
                instructions.write_text("Existing instructions.\n")
                before = {p.relative_to(self.target): p.read_bytes() for p in self.target.rglob("*") if p.is_file()}
                self.call(runner, "install", "--dry-run")
                self.assertFalse((self.target / ".github/ai-qa/manifest.json").exists())
                self.call(runner, "install")
                manifest_path = self.target / ".github/ai-qa/manifest.json"
                manifest = json.loads(manifest_path.read_text())
                self.assertEqual(manifest["framework_version"], "1.0.0")
                self.assertEqual(len(manifest["files"]), 6)
                self.assertNotIn(".github/instructions/qa-rendered.instructions.md", manifest["files"])
                self.assertFalse((self.target / ".github/ai-qa/project").exists())
                self.assertIn("Existing instructions.", instructions.read_text())
                self.call(runner, "verify")
                self.assertIn("project layer is not configured", self.call(runner, "verify").stdout)

                edited = self.target / ".github/ai-qa/framework/method/rules.md"
                edited.write_text("project edit\n")
                (self.source / ".github/ai-qa/framework/method/retired.md").unlink()
                self.framework_file("ai-qa/framework/method/new.md", "New framework file.\n")
                (self.source / "VERSION").write_text("1.1.0\n")
                (self.source / "docs/migrations.md").write_text("# Migrations\n\nrefresh-required: 1.1.0\n")
                output = self.call(runner, "update").stdout
                self.assertIn("qa-configure refresh", output)
                self.assertEqual(edited.read_text(), "project edit\n")
                self.assertEqual(Path(str(edited) + ".ai-qa-new").read_text(), "Framework v1.\n")
                self.assertFalse((self.target / ".github/ai-qa/framework/method/retired.md").exists())
                self.assertTrue((self.target / ".github/ai-qa/framework/method/new.md").exists())
                self.call(runner, "verify", expected=1)
                self.call(runner, "uninstall")
                self.assertEqual(edited.read_text(), "project edit\n")
                self.assertFalse(manifest_path.exists())
                self.assertEqual((self.target / "README.md").read_bytes(), before[Path("README.md")])
                self.assertEqual((self.target / ".github/workflows/ci.yml").read_bytes(), before[Path(".github/workflows/ci.yml")])
                self.assertEqual(instructions.read_text(), "Existing instructions.\n")

    def test_collision_prefix_and_reference_rewrite(self):
        for runner in runners():
            self.fresh(runner)
            with self.subTest(runner=runner[0]):
                (self.target / ".github/agents").mkdir(parents=True)
                collision = self.target / ".github/agents/qa-local.agent.md"
                collision.write_text("project agent\n")
                self.call(runner, "install", expected=1)
                self.call(runner, "install", "--prefix", "custom")
                renamed = self.target / ".github/agents/custom.agent.md"
                self.assertTrue(renamed.exists())
                self.assertIn("custom-plan", renamed.read_text())
                self.assertEqual(collision.read_text(), "project agent\n")
                self.call(runner, "verify")
                self.call(runner, "install", target=self.source, expected=1)

    def test_purge_confirmation_and_project_data_preservation(self):
        for runner in runners():
            self.fresh(runner)
            with self.subTest(runner=runner[0]):
                project = self.target / ".github/ai-qa/project/project.md"
                project.parent.mkdir(parents=True)
                project.write_text("project layer\n")
                work = self.target / "qa-work/task/index.md"
                work.parent.mkdir(parents=True)
                work.write_text("work item\n")
                self.call(runner, "install")
                self.call(runner, "uninstall", "--purge", expected=1)
                self.assertTrue(project.exists())
                self.assertTrue((self.target / ".github/ai-qa/manifest.json").exists())
                self.call(runner, "uninstall")
                self.assertTrue(project.exists())
                self.assertTrue(work.exists())
                self.call(runner, "install")
                self.call(runner, "uninstall", "--purge", "--yes")
                self.assertFalse(project.exists())
                self.assertFalse(work.exists())

    def test_dry_run_collision_and_manifest_path_validation(self):
        for runner in runners():
            self.fresh(runner)
            with self.subTest(runner=runner[0]):
                self.call(runner, "install", "--dry-run")
                self.assertFalse(any(p.is_file() for p in self.target.rglob("*")))
                self.call(runner, "install")
                manifest_path = self.target / ".github/ai-qa/manifest.json"
                manifest = json.loads(manifest_path.read_text())
                manifest["files"][".github/ai-qa/project/project.md"] = "0" * 64
                manifest_path.write_text(json.dumps(manifest))
                self.call(runner, "uninstall", expected=1)


class RealFrameworkTests(unittest.TestCase):
    def test_install_update_uninstall_with_shipped_framework(self):
        with tempfile.TemporaryDirectory(prefix="ai-qa-real-") as temporary:
            base = Path(temporary)
            for name, runner in runners():
                with self.subTest(runner=name):
                    target = base / name
                    (target / "src").mkdir(parents=True)
                    (target / "src/app.py").write_text("print('app')\n")
                    (target / ".gitignore").write_text("*.pyc\n")
                    subprocess.run(["git", "init", "-q", str(target)], check=True)
                    before = {p.relative_to(target): p.read_bytes() for p in target.rglob("*") if p.is_file() and ".git" not in p.parts}
                    installer = ROOT / ("install.sh" if name == "sh" else "install.ps1")
                    command = runner + ([str(installer)] if name == "sh" else ["-File", str(installer)])

                    def invoke(action):
                        result = subprocess.run(command + [action, str(target)], cwd=ROOT, capture_output=True, text=True, input="")
                        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

                    invoke("install")
                    invoke("verify")
                    framework = target / ".github/ai-qa/framework/method/safety.md"
                    framework.write_text("local edit\n")
                    invoke("update")
                    self.assertTrue(Path(str(framework) + ".ai-qa-new").exists())
                    invoke("uninstall")
                    self.assertEqual(framework.read_text(), "local edit\n")
                    framework.unlink()
                    Path(str(framework) + ".ai-qa-new").unlink()
                    after = {p.relative_to(target): p.read_bytes() for p in target.rglob("*") if p.is_file() and ".git" not in p.parts}
                    self.assertEqual(after, before)


if __name__ == "__main__":
    unittest.main()