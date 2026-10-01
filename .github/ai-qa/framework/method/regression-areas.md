# Regression Risk Matrix

The Regression Risk Matrix ensures that system-wide impact is evaluated beyond the immediate scope of the ticket. It forces systemic thinking and prevents purely local validation. This section is **mandatory** in every test plan document.

## Risk levels

| Level | Meaning |
|---|---|
| **LOW** | Minimal impact, existing tests sufficient |
| **MEDIUM** | Some impact, targeted testing recommended |
| **HIGH** | Significant impact, regression testing required |
| **CRITICAL** | Could break core functionality, immediate attention needed |

## Risk matrix

Complete the following table for every ticket:

| Area | Risk Level | Why? | Regression Needed? | Automation Update Needed? |
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

These names denote risk categories, not a claim that the project implements every component. For each row give a LOW/MEDIUM/HIGH/CRITICAL rating, a source-backed explanation, whether regression testing is needed and whether automation needs updating. Use `unknown` for unanswered yes/no fields; never treat missing evidence as LOW.

## Mandatory analysis rules

- Never mark all categories as LOW without justification
- Escalate risk if feature flags modify runtime behaviour
- Escalate risk if logic is environment-dependent
- Escalate risk if caching or async behaviour is involved
- Escalate risk if database schema or persistence logic is modified
- Escalate risk if endpoint-level gating is introduced
- Escalate risk if authentication or authorisation flow changes

Flag runtime switches, environment-sensitive paths, asynchronous/cache semantics, schema/writes, endpoint gating and authentication for closer scrutiny. The overall risk is the highest supported row rating, not an average.

## High / Critical risk handling

If any category is marked **HIGH** or **CRITICAL**, additionally:

1. Propose targeted regression scenarios for that area.
2. Recommend automation reinforcement.
3. Highlight potential production impact.
4. Suggest rollout validation strategy, if applicable.

For each HIGH/CRITICAL row provide a concrete scenario, automation reinforcement, possible production consequence and relevant rollout/rollback check. Never remove manual coverage of HIGH/CRITICAL risks merely to reduce scenario count.

## Example entry

| Area | Risk Level | Why? | Regression Needed? | Automation Update Needed? |
|---|---|---|---|---|
| Feature Flags | HIGH | Runtime behaviour changes without redeploy | Yes | Yes |
| Database Layer | MEDIUM | New write path added, existing reads unchanged | Yes | No |
| Backward Compatibility | LOW | Internal change only, no public contract change | No | No |
