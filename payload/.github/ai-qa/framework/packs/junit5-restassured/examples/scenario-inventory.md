# JUnit 5 + REST Assured — sample test inventory (not executed)

For a **hypothetical** `POST /widgets` contract with a required name, demonstrate case selection without asserting undocumented response codes.

| Source | Level | Scenario | Request | Expected contract result | Status |
|---|---|---|---|---|---|
| Hypothetical `POST /widgets` | Integration | Minimum valid input | Name present | Documented success status/body | Proposed, unverified |
| Same | Integration | Required name omitted | Name absent | Documented validation status/body, if defined | Proposed, unverified |
| Same | Integration | Optional attributes included | All documented fields | Documented success shape | Proposed, unverified |

Do not run a state-changing POST against shared/prod data or infer 400 versus 422. No Java source files or package changes are part of this example.
