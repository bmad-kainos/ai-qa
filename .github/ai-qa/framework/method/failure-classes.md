# Failure classification and safe iteration

Collect the failing test ID, exact assertion/error, expected and observed behaviour,
commit, environment, run time, logs and relevant requirement before assigning a cause.
Compare with the last reliable baseline and identify whether the observed outcome is:

| Class | Evidence to seek |
|---|---|
| Product regression | Reproducible contract violation in application behaviour. |
| Test defect / obsolete expectation | Faulty assertion, stale spec, bad fixture or wrong selector. |
| Flaky / nondeterministic test | Outcome changes on comparable runs; timing/order/race evidence. |
| Test data / access | Missing, contaminated or unauthorised fixture or account. |
| Environment / external dependency | Outage, configuration or integration failure. |
| Infrastructure / CI | Runner, resource or pipeline fault distinct from product behaviour. |
| Unknown / blocked | Insufficient or conflicting evidence. |

State confidence and a falsifiable next check; a single HTTP/CI error alone proves
neither a product bug nor flakiness. A rerun, if safe and approved where required,
does not erase the original failure. Fix only work-item-owned **test** defects,
up to three measured attempts with an actual targeted rerun after each; stop if
unchanged, uncertain or blocked. Do not alter product code, weaken assertions,
hide failures or change deployment state. Draft, but do not publish, a bug report
for evidence-backed application defects.
