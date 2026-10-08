# Questions and clarification

Ask only when an essential scope, requirement, target branch, contradictory fact, access dependency or gated side effect cannot be resolved from available evidence. Start with a read-only repository scan and current project context. Never ask what the repository already answers. When ambiguity is non-blocking, record it and proceed with a bounded, clearly stated assumption.

## Missing required input: ask, never bare-refuse

When a skill cannot continue because required input is missing, never end with a bare refusal such as "I need more context". Instead:

1. Name exactly which required fields are missing (after checking supplied text and the repository).
2. Ask for them in one concise question or a short numbered list, stating what is needed for each.
3. Continue the work once answered.
4. If the user cannot or will not supply a field, mark it `Not provided` and still produce the draft or output, labelling the limitation. Do not fabricate values.

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
