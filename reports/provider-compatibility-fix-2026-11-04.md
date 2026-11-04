# Provider structured-tool compatibility fix

Audit date: November 4, 2026. This change is confined to the hackathon submission repository. The original Tuka checkout, production deployments, and the pinned integrated event commit are unchanged.

## Diagnosis

The previous live runs authenticated and returned HTTP 422 from `/api/meta/interpret`. The handler only accepted `choices[0].message.tool_calls`, required exactly one call, and always decoded `function.arguments` as a JSON string. It also sent an object-valued `tool_choice` that the Meta adapter downgraded to `auto`. That combination was too narrow for OpenAI-compatible gateways: a provider may return object arguments, structured content blocks, or strict JSON content when tool calls are represented differently.

Baseten documentation says Muse Spark Open supports tool calling and reasoning output through its OpenAI-compatible Model API ([Baseten announcement](https://www.baseten.co/blog/muse-spark-open-launch)). The compatibility fix therefore keeps tool calling required and normalizes only documented structured response shapes. It does not treat prose as an intent.

## Fix

- Journey interpretation now sends `tool_choice: "required"` to both providers, while leaving the shared provider fallback, timeout, authentication and redirect behavior unchanged.
- Added a strict normalizer for:
  - OpenAI `message.tool_calls` with JSON-string arguments.
  - OpenAI-compatible `tool_calls` with already-decoded object arguments.
  - Structured `tool_use`/`function` content blocks.
  - A content string only when it is a complete JSON object; prose and fenced JSON are rejected.
- Every normalized result still passes the existing allow-list, place, date/time, preference and walking-limit validator. Route IDs, trips, coordinates, predictions and arbitrary model fields remain rejected.
- Multiple calls, missing arguments, malformed JSON, unsupported content blocks and ordinary text remain invalid.
- Added provider-shape fixtures for Meta and Baseten plus negative regression cases.
- Added `patches/provider-tool-compat.patch`; `scripts/setup-judges.sh` verifies the pinned event tree first, then applies this reviewable post-event contribution. The integrated event commit is not replaced.

## Local evidence

- Fresh reconstruction: **PASS**. The pinned event tree still hashes to `bd6b36ffb91bfc8f0ea8c12e972d58aabbf11a36` before the compatibility patch is applied.
- Reconstruction patch application: **PASS** in a clean temporary checkout.
- Existing test suite: **198 tests, 198 passed**.
- New compatibility fixtures: **9 tests, 9 passed** (standard Meta shape, Baseten object arguments, structured blocks, strict JSON, valid provider normalization, and malformed/missing/multiple/unsupported cases).
- Meta production build: **PASS**, 65 assets generated.
- No live requests were made after the previous authorized one-request-per-provider test. Credentials remain local and ignored.

## Bounded live retest plan — approval required

After explicit approval, run exactly two local authenticated requests:

1. One Meta request to `/api/meta/interpret`, with fallback disabled and no retry.
2. One Baseten request to `/api/meta/interpret`, with fallback disabled and no retry, using `meta-models/muse-spark-open-1026`.

Record only HTTP status, provider label, elapsed time and whether the returned intent passed schema validation. Do not log raw provider responses or secrets. Stop after the two requests, regardless of outcome. No deployment, merge or production change is included.
