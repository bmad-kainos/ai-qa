from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / ".github/skills/qa-review-tests/SKILL.md"


class CodeReviewQualityGateTests(unittest.TestCase):
    def test_code_mode_requires_all_five_explicit_gate_results(self):
        skill = SKILL.read_text(encoding="utf-8")
        headings = (
            "Conventions",
            "Good practice",
            "Correct coverage",
            "No duplication",
            "Safe by default",
        )

        for heading in headings:
            with self.subTest(heading=heading):
                self.assertIn(f"| {heading} | <PASS / FAIL> |", skill)

        self.assertIn("Insufficient evidence is `FAIL`, not an assumed pass", skill)

    def test_code_mode_preserves_findings_columns_and_tags_gate_findings(self):
        skill = SKILL.read_text(encoding="utf-8")

        self.assertIn("| Severity | Finding | Evidence | Recommendation |", skill)
        self.assertIn("Tag each finding in the existing `Finding` cell", skill)
        self.assertIn("Keep the existing severity levels, ranking and findings-table columns unchanged", skill)


if __name__ == "__main__":
    unittest.main()
