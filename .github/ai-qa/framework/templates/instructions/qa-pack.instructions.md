---
applyTo: "<CONFIRMED_PACK_TEST_GLOB>"
---

# AI-QA selected-pack guidance template

> Inert generic source. For each confirmed pack, Configure may render a
> separate `.github/instructions/qa-<pack>.instructions.md` only after L5
> approval, replacing `<pack>` and narrowing `applyTo` to actual test paths.
> Never enable overlapping rules solely because file extensions match.

<!-- ai-qa:managed:start -->
- Follow `.github/ai-qa/project/conventions/testing.md`, the confirmed
  framework pack under `.github/ai-qa/framework/packs/`, and existing tests.
- Use deterministic assertions, safe data and fixture cleanup. For contract-backed
  APIs cover applicable success, invalid, auth and constrained boundary cases.
- Keep `FR`/`NFR` links; do not weaken assertions or invent execution results.
- L1 permits local test edits on a non-default branch after an orchestrated plan is
  approved; it has no separate action gate. L3 gates risky/long runs; L4 external writes.
<!-- ai-qa:managed:end -->

<!-- ai-qa:user -->
Project-authored pack guidance; preserve verbatim on refresh.
<!-- /ai-qa:user -->
