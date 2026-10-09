from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RequestedLevelMismatchTests(unittest.TestCase):
    def test_automation_plan_shows_both_levels_and_pending_confirmation(self):
        skill = (ROOT / ".github/skills/qa-automation-plan/SKILL.md").read_text(encoding="utf-8")

        self.assertIn(
            "| Scenario / requirement | Decision | Requested level | Recommended level | Final level / status |",
            skill,
        )
        self.assertIn("Automate (blocked)** with confirmation pending", skill)
        self.assertIn("ask the user whether to use the requested or recommended level", skill)
        self.assertIn("to **N/A** and apply no mismatch rule", skill)

    def test_test_generation_waits_for_confirmation(self):
        skill = (ROOT / ".github/skills/qa-generate-tests/SKILL.md").read_text(encoding="utf-8")

        self.assertIn("Do not generate tests for that scenario until the user confirms", skill)
        self.assertIn("a request alone is not confirmation", skill)
        self.assertIn("pending mismatch is not confirmation", skill)
        self.assertIn("| Requirement/source | Requested level | Recommended level | Final level / status |", skill)
        self.assertIn("| Test | Requested level | Recommended level | Final level / status |", skill)
        self.assertIn("| Test | Endpoint | Requested level | Recommended level | Final level / status |", skill)
        self.assertLess(skill.index("Level mismatch gate"), skill.index("### API test method"))
        self.assertEqual(skill.count("Do not generate tests for that scenario until the user confirms"), 1)

    def test_shared_criteria_defines_requested_level_confirmation(self):
        criteria = (ROOT / ".github/ai-qa/framework/method/automation-criteria.md").read_text(encoding="utf-8")

        self.assertIn("compare the two for each scenario", criteria)
        self.assertIn("ask the user to confirm whether to use the requested or recommended level", criteria)
        self.assertIn("do not generate its tests", criteria)


if __name__ == "__main__":
    unittest.main()
