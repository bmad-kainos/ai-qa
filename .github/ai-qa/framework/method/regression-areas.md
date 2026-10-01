# Mandatory regression assessment

Every ticket test plan includes all **13** areas below; these names denote risk
categories rather than a claim that the project implements every component. For
each row give a LOW/MEDIUM/HIGH/CRITICAL rating, source-backed explanation,
whether regression testing is needed, and whether automation needs updating.
Use `unknown` for unanswered yes/no fields; never treat missing evidence as LOW.

| Area | Risk | Evidence and reason | Regression needed? | Automation update? |
|---|---|---|---|---|
| API Behaviour | | | | |
| Existing Endpoints | | | | |
| Feature Flags | | | | |
| Caching | | | | |
| Authentication / Authorisation | | | | |
| API Gateway | | | | |
| Backend Logic | | | | |
| Database Layer | | | | |
| Data Integrity | | | | |
| Logging / Monitoring | | | | |
| Environment Configuration | | | | |
| CI/CD Pipeline | | | | |
| Backward Compatibility | | | | |

LOW means limited impact with sufficient existing safeguards; MEDIUM calls for focused
checking; HIGH requires regression validation; CRITICAL threatens essential service
behaviour and needs immediate attention. Flag changes in runtime switches,
environment-sensitive paths, asynchronous/cache semantics, schema/writes, endpoint
gating and auth for closer scrutiny. All-LOW ratings require individual justification.
For every HIGH/CRITICAL row supply a concrete scenario, automation reinforcement,
possible production consequence and relevant rollout/rollback check. The plan's
overall risk is the highest supported row rating, not an average.
