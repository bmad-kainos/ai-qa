# Questions and clarification

Ask only when an essential scope, requirement, target branch, contradictory fact, access dependency or gated side effect cannot be resolved from available evidence. Start with a read-only repository scan and current project context. Never ask what the repository already answers. When ambiguity is non-blocking, record it and proceed with a bounded, clearly stated assumption.

## Missing required input: draft first, then ask

When required input is missing, never stop or end with a bare refusal such as "I need more context". Draft first, then ask:

1. Scan the user's text, branch, runs, logs and repository first; never ask what they already answer.
2. Produce the draft now with what is known. Mark each gap `Not provided`, keep the status `DRAFT` and note the gaps in confidence. Do not fabricate values.
3. In the same reply, ask at most 5 targeted questions, ordered by how much each answer improves the output. Build each from something the user said (the named element, page, trigger or symptom) and say what it unlocks. Answers are optional. Skip questions when only nonessential fields remain; this rule overrides the "ask only when essential" guidance above for required fields only.
4. When answers arrive, re-draft. Ask a follow-up only for a still-significant gap, and stop after two rounds.

Mark missing required fields `Not provided` and missing optional fields `Unknown`.

Exception: when almost nothing is known (no feature, page or symptom), skip the draft and ask the 2 or 3 anchoring questions, then draft. With nothing to build on, use: what were you doing and on which page or feature, what went wrong, and what did you expect.

## Option-A interview format

Ask **one question at a time**. Show the evidence and why the answer matters, then give a recommendation and alternatives:

```md
**Question <n> — <topic>**

<Evidence found and the decision this answer unlocks.>

**Option A (recommended):** <evidence-backed value>
**Option B:** <reasonable alternative>
```

For Configure, inspect first and ask only about conflicts, behaviour-relevant inferences, inaccessible checks or relevant missing information. Interview project identity/ownership, stack and test framework, layout and commands, testing conventions, code style, integrations and Do Not constraints only when not already evident. Offer **accept all** so the user can accept all detected recommendations; keep ambiguous values explicitly unknown rather than fabricating conventions. If the user says “not sure”, retain an unresolved placeholder or a clearly labelled candidate rather than claiming it was confirmed. Ask one optional constraints question at most when no relevant constraints were discovered.

Never ask for secrets, credentials, token values or passwords. Ask only for environment-variable names and never include their values. Do not ask the user to restate a fact visible in the repository.

For a full workflow, require sufficient ticket/feature context and a confirmed test branch if implementation verification is requested. If configured provider retrieval fails, retry once, then ask for pasted title, description and acceptance criteria rather than blocking indefinitely. Missing optional integrations do not justify repeated questions or invented results.

At action gates show exact action, target, payload/diff or command and side effects. Design approval does not authorise test generation, branch creation, full/shared test runs, publication, push or installation. For Jira/Confluence show exact content and confirmed destination immediately before asking for explicit affirmative approval; ask again after any edit.
