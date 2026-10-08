"""Cheap lint checks for skill prompt files (spike #13)."""

from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / ".github" / "skills"
LEGACY = ["requirement.md", "context.md", "coverage.md", "design.md",
          "regression.md", "automation.md", "review.md", "test-plan.md"]
LEGACY_PATTERN = re.compile(r"(?<![\w-])(?:%s)" % "|".join(map(re.escape, LEGACY)))
TEMPLATE_REFERENCE = ".github/ai-qa/framework/templates/test-plan.md"


def skill_files():
    return sorted(SKILLS.glob("**/*.md"))


def front_matter(text):
    match = re.match(r"\A---\r?\n(.*?)\r?\n---(?:\r?\n|\Z)", text, re.S)
    return match.group(1) if match else None


def has_legacy_artefact_filename(line):
    return bool(LEGACY_PATTERN.search(line.replace(TEMPLATE_REFERENCE, "")))


class SkillLintTests(unittest.TestCase):
    def test_front_matter_name_matches_directory(self):
        for d in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
            text = (d / "SKILL.md").read_text(encoding="utf-8")
            metadata = front_matter(text)
            self.assertIsNotNone(metadata, d.name)
            match = re.search(r"^name:\s*(\S+)", metadata, re.M)
            self.assertIsNotNone(match, d.name)
            self.assertEqual(match.group(1).strip("\"'"), d.name)

    def test_front_matter_must_be_at_start_of_file(self):
        text = "# Example\n\nname: qa-test-plan\n"
        self.assertIsNone(front_matter(text))

    def test_referenced_framework_files_exist(self):
        pattern = re.compile(r"\.github/ai-qa/framework/[\w./-]+?\.md")
        for f in skill_files():
            for ref in pattern.findall(f.read_text(encoding="utf-8")):
                self.assertTrue((ROOT / ref).exists(), f"{f.name}: {ref}")

    def test_no_legacy_artefact_filenames(self):
        for f in skill_files():
            for n, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
                if has_legacy_artefact_filename(line) and not re.search(r"legacy|fallback", line, re.I):
                    self.fail(f"{f.relative_to(ROOT)}:{n}: {line.strip()}")

    def test_path_qualified_legacy_filenames_are_detected(self):
        self.assertTrue(has_legacy_artefact_filename("Write qa-work/123/requirement.md"))
        self.assertTrue(has_legacy_artefact_filename("Write outputs/test-plan.md"))
        self.assertFalse(has_legacy_artefact_filename(f"Use {TEMPLATE_REFERENCE}"))
        self.assertTrue(has_legacy_artefact_filename(
            f"Use {TEMPLATE_REFERENCE} and write outputs/test-plan.md"))


if __name__ == "__main__":
    unittest.main()
