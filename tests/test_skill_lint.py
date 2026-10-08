"""Cheap lint checks for skill prompt files (spike #13)."""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / ".github" / "skills"
LEGACY = ["requirement.md", "context.md", "coverage.md", "design.md",
          "regression.md", "automation.md", "review.md", "test-plan.md"]


def skill_files():
    return sorted(SKILLS.glob("**/*.md"))


class SkillLintTests(unittest.TestCase):
    def test_front_matter_name_matches_directory(self):
        for d in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
            text = (d / "SKILL.md").read_text(encoding="utf-8")
            match = re.search(r"^name:\s*(\S+)", text, re.M)
            self.assertIsNotNone(match, d.name)
            self.assertEqual(match.group(1).strip("\"'"), d.name)

    def test_referenced_framework_files_exist(self):
        pattern = re.compile(r"\.github/ai-qa/framework/[\w./-]+?\.md")
        for f in skill_files():
            for ref in pattern.findall(f.read_text(encoding="utf-8")):
                self.assertTrue((ROOT / ref).exists(), f"{f.name}: {ref}")

    def test_no_legacy_artefact_filenames(self):
        pattern = re.compile(r"(?<![\w/-])(?:%s)" % "|".join(map(re.escape, LEGACY)))
        for f in skill_files():
            for n, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
                if pattern.search(line) and not re.search(r"legacy|fallback", line, re.I):
                    self.fail(f"{f.relative_to(ROOT)}:{n}: {line.strip()}")


if __name__ == "__main__":
    unittest.main()
