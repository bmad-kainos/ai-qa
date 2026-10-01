#!/usr/bin/env python3
"""Calculate reproducible run statistics from structured CI history.

This optional tool runs from the AI-QA checkout, never from an installed project.
Input is a JSON array of runs with sha, duration_seconds, outcome and optional
run_id. No credentials, network access or third-party packages are needed.
"""

import argparse
import json
import math
import sys
from collections import defaultdict


def percentile(values, percentage):
    if not values:
        return None
    ordered = sorted(values)
    index = (len(ordered) - 1) * percentage / 100
    lower = math.floor(index)
    upper = math.ceil(index)
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (index - lower)


def statistics(runs):
    durations = []
    by_sha = defaultdict(list)
    for run in runs:
        if not isinstance(run, dict):
            raise ValueError("each run must be an object")
        sha = run.get("sha")
        outcome = run.get("outcome")
        duration = run.get("duration_seconds")
        if not isinstance(sha, str) or not sha or outcome not in ("passed", "failed"):
            raise ValueError("each run needs a nonempty sha and passed/failed outcome")
        if isinstance(duration, bool) or not isinstance(duration, (int, float)) or not math.isfinite(duration) or duration < 0:
            raise ValueError("duration_seconds must be a nonnegative finite number")
        durations.append(duration)
        by_sha[sha].append(outcome)
    retries = sum(max(0, len(outcomes) - 1) for outcomes in by_sha.values())
    flaky = sorted(sha for sha, outcomes in by_sha.items() if "passed" in outcomes and "failed" in outcomes)
    return {
        "run_count": len(runs),
        "duration_seconds": {
            "p50": percentile(durations, 50),
            "p90": percentile(durations, 90),
            "p95": percentile(durations, 95),
        },
        "same_sha_reruns": retries,
        "flaky_shas": flaky,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("runs", help="JSON array of CI runs, or - for stdin")
    args = parser.parse_args()
    try:
        if args.runs == "-":
            data = json.load(sys.stdin)
        else:
            with open(args.runs, encoding="utf-8") as source:
                data = json.load(source)
        if not isinstance(data, list):
            raise ValueError("input must be a JSON array")
        print(json.dumps(statistics(data), indent=2))
    except (OSError, ValueError) as exc:
        parser.exit(2, f"qa-stats: {exc}\n")


if __name__ == "__main__":
    main()
