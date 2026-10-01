import importlib.util
import pathlib
import unittest


SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "tools" / "qa-stats.py"
SPEC = importlib.util.spec_from_file_location("qa_stats", SCRIPT)
qa_stats = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(qa_stats)


class StatsTests(unittest.TestCase):
    def test_empty_data_has_no_invented_metrics(self):
        self.assertEqual(qa_stats.statistics([])["duration_seconds"]["p95"], None)

    def test_same_sha_mixed_outcomes_are_flaky(self):
        result = qa_stats.statistics([
            {"sha": "a", "outcome": "failed", "duration_seconds": 10},
            {"sha": "a", "outcome": "passed", "duration_seconds": 20},
            {"sha": "b", "outcome": "passed", "duration_seconds": 30},
        ])
        self.assertEqual(result["duration_seconds"]["p50"], 20)
        self.assertEqual(result["duration_seconds"]["p95"], 29)
        self.assertEqual(result["same_sha_reruns"], 1)
        self.assertEqual(result["flaky_shas"], ["a"])

    def test_bad_runs_are_rejected(self):
        with self.assertRaises(ValueError):
            qa_stats.statistics([{"sha": "x", "outcome": "failed", "duration_seconds": -1}])


if __name__ == "__main__":
    unittest.main()
