# Live AI and authenticated UI verification

Audit date: November 4, 2026. This report records the final verification boundary without exposing credentials or making an unapproved provider request.

## Authentication and local UI

The reconstructed Worker was started with the local-only compatibility override:

```bash
npx wrangler dev --config wrangler.meta.jsonc --port 8794 --compatibility-date 2026-10-13
```

| Check | Result | Evidence |
| --- | --- | --- |
| Login page renders | PASS | `GET /login` returned HTTP 200 and contained the judging-build sign-in form. |
| Unauthenticated application redirect | PASS | `GET /` returned HTTP 303 with `/login?next=%2F`. |
| Invalid credentials rejected | PASS | `POST /auth/login` with a deliberately invalid password returned HTTP 303 to `/login?error=invalid`. No session cookie was accepted. |
| Protected API without session | PASS | `GET /api/cities` returned HTTP 401 with the generic sign-in error. |
| Valid login and session persistence | BLOCKED | No authorized local `META_AUTH_PASSWORD` is present in the submission checkout or environment. No bypass or guessed password was attempted. |
| Authenticated map, cities, routes, journey planner and Copilot UI | BLOCKED | These require a valid session first. Existing mocked tests cover the server contracts; they are not browser evidence. |

The login form response contained no provider endpoint, token variable name, or credential value. Authentication uses a server-issued HMAC session cookie with `HttpOnly`, `Secure`, `SameSite=Lax`, `Path=/`, and a 12-hour lifetime.

## Provider architecture

Static inspection of the reconstructed application found:

- Meta direct endpoint: `https://api.meta.ai/v1/chat/completions`.
- Baseten endpoint: `https://inference.baseten.co/v1/chat/completions`.
- Meta model default: `muse-spark-1.3`.
- Baseten model: explicit `BASETEN_MODEL`; the hackathon model used by tests is `meta-models/muse-spark-open-1026`.
- Meta credentials: `MODEL_API_KEY`, `META_AI_TOKEN`, or `META_API_KEY`.
- Baseten credentials: `BASETEN_API_KEY` and `BASETEN_MODEL`.
- Provider order: Meta first by default; `MODEL_PRIMARY_PROVIDER=baseten` or `MODEL_PROVIDER=baseten` makes Baseten primary. Fallback can be disabled with `MODEL_FALLBACK_ENABLED=false`.
- Requests stay server-side, use bearer authentication, manual redirects, ten-second timeouts and provider-specific tool/token adaptation.
- Journey interpretation is restricted to a validated `plan_transit_journey` tool. The model cannot provide route IDs, trips, coordinates or departure predictions.

## Real inference

| Provider | Endpoint/model identified | Real inference | Response parsing |
| --- | --- | --- | --- |
| Meta | PASS — endpoint and model configuration inspected | BLOCKED — no authorized live request made | PASS in mocked contract tests only |
| Baseten | PASS — endpoint and explicit model configuration inspected | BLOCKED — `BASETEN_API_KEY` and `BASETEN_MODEL` are absent | PASS in mocked contract tests only |

The shell environment exposed a `MODEL_API_KEY` variable name, but this audit did not read its value, log it, or send a request with it. A live call could be billable or consume hackathon credits. Before any live test, explicit approval is required for:

1. Provider and exact model.
2. One request maximum per provider, plus whether one fallback request is authorized.
3. Maximum cost or confirmation that the request is covered by the supplied hackathon credits.

No live fallback inference was attempted. Mocked tests cover successful responses, timeout, authentication failure, rate limiting, malformed model output, provider fallback, both providers unavailable, transport-only scope, and transit-context grounding.

## Security checks

- Browser bundles contain no API key names, provider endpoints or credential values.
- Protected AI routes return 401 without a session.
- Provider calls are server-side.
- Login errors are generic and do not reveal credentials.
- No credentials were written to screenshots, logs, reports or Git.
- No `.env` or `.dev.vars` secret file is tracked.

## Remaining action

To complete the blocked checks, configure an authorized local `META_AUTH_PASSWORD` in the ignored reconstructed checkout environment and explicitly approve a bounded live smoke-test plan. Until then, the correct status is **BLOCKED**, not live verified.
