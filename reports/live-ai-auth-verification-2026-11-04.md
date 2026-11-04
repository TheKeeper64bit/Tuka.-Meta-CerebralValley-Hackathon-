# Live AI and authenticated UI verification

Audit date: November 4, 2026. Verification was run only in the reconstructed checkout at `/home/rand0m/Desktop/Tuka-Meta-CerebralValley-Hackathon/.reconstructed-tuka`. The original Tuka checkout was not modified. No deployment or merge was performed.

## Configuration and budget

An ignored, mode-600 `.dev.vars` was created in the reconstructed checkout. It contains a locally generated test password, the existing local Meta credential, the existing local Baseten credential, and the exact hackathon model identifier `meta-models/muse-spark-open-1026`. Secret values were never printed, committed, or included in logs. `MODEL_FALLBACK_ENABLED=false` was set for both runs.

The Baseten library lists Muse Spark Open at $1.25/M input tokens and $4.25/M output tokens. Each smoke test was limited by the application request to a single call with a small prompt and a 500-token completion ceiling; even a conservative 2,000-input/500-output upper bound is approximately $0.0045 for Baseten. Meta's hackathon materials describe free Model API credits, so the authorized one-request Meta smoke test was covered by the supplied credits. No fallback request was authorized or attempted.

## Authentication and local UI

The reconstructed Worker was started with the local-only compatibility override:

```bash
/home/rand0m/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node \
  ./node_modules/wrangler/bin/wrangler.js dev \
  --config wrangler.meta.jsonc --port 8796 \
  --compatibility-date 2026-10-13 --env-file .dev.vars \
  --var MODEL_PROVIDER:baseten
```

| Check | Result | Evidence |
| --- | --- | --- |
| Login page renders | PASS | `GET /login` returned HTTP 200. |
| Unauthenticated application redirect | PASS | Earlier baseline check: `GET /` returned HTTP 303 to `/login?next=%2F`. |
| Invalid credentials rejected | PASS | Earlier baseline check: invalid login returned HTTP 303 to `/login?error=invalid`. |
| Valid login and session persistence | PASS | Both live runs returned HTTP 303 to `/` and set a session cookie (304-byte cookie jar; value withheld). |
| Authenticated application assets | PASS | Browser-authenticated run loaded `/`, map CSS/JS, city providers, planner, news, live, Meta UI and service worker assets with HTTP 200. |
| Protected APIs without session | PASS | Earlier baseline check: `GET /api/cities` returned HTTP 401. |
| Secrets in browser output | PASS | No credential values were printed or placed in reports/screenshots. |

The login form response contains no provider endpoint, token variable name, or credential value. Authentication uses a server-issued HMAC session cookie with `HttpOnly`, `Secure`, `SameSite=Lax`, `Path=/`, and a 12-hour lifetime.

## Provider architecture

Static inspection of the reconstructed application found:

- Meta direct endpoint: `https://api.meta.ai/v1/chat/completions`.
- Baseten endpoint: `https://inference.baseten.co/v1/chat/completions`.
- Meta model default: `muse-spark-1.3`.
- Baseten model: explicit `BASETEN_MODEL`; configured for this run as `meta-models/muse-spark-open-1026`.
- Meta credentials: `MODEL_API_KEY`, `META_AI_TOKEN`, or `META_API_KEY`.
- Baseten credentials: `BASETEN_API_KEY` and `BASETEN_MODEL`.
- Provider order: Meta first by default; `MODEL_PROVIDER=baseten` makes Baseten primary. Fallback was disabled for these tests.
- Requests stay server-side, use bearer authentication, manual redirects and ten-second timeouts.
- Journey interpretation is restricted to a validated `plan_transit_journey` tool. The model cannot provide route IDs, trips, coordinates or departure predictions.

## Authorized real inference

Exactly one request was sent to each provider through `/api/meta/interpret`. No direct second attempt and no fallback call was made.

| Provider | Request result | Response parsing | Interpretation |
| --- | --- | --- | --- |
| Meta | HTTP 422, 5.58 s | Failed application tool-contract validation | The request reached the application/provider path, but the returned model response did not contain exactly one valid `plan_transit_journey` tool call. No usable intent was accepted. |
| Baseten | HTTP 422, 2.06 s | Failed application tool-contract validation | The request reached the application/provider path, but the returned model response did not contain exactly one valid `plan_transit_journey` tool call. No usable intent was accepted. |

The application intentionally converts malformed or non-tool model output to HTTP 422. Because the endpoint does not expose upstream response bodies, this audit cannot claim that either provider produced a usable inference. The exact Baseten model was exercised once; no retry was made when the tool contract was not met.

No live fallback inference was attempted. Existing mocked tests cover successful responses, timeout, authentication failure, rate limiting, malformed model output, provider fallback, both providers unavailable, transport-only scope, and transit-context grounding.

## Security and repository checks

- Browser bundles contain no API key names, provider endpoints or credential values.
- Protected AI routes return 401 without a session.
- Provider calls are server-side.
- Login errors are generic and do not reveal credentials.
- No credentials were written to screenshots, logs, reports or Git.
- `.dev.vars*` and `.env*` remain ignored; the local `.dev.vars` is outside the tracked tree.
- The original Tuka repository and production deployments were not changed.

## Test evidence

Before this live run, the reconstructed checkout passed 198 Node tests (100 + 64 + 34), standalone checks and the Meta build. GitHub Actions also passed on the audit branch at commit `b1e5e4034aec8190abfbc68bb3a235501bc3d550` (run `41870616644`). No application source was changed during this live-configuration step, so CI was not rerun for code changes.

## Remaining limitation

Authentication and the local application shell are verified. The two authorized provider requests were made without retry and both failed the strict structured-tool contract, so live journey interpretation remains **not verified as usable**. A future fix should first inspect the provider-specific tool-call response shape and add a provider adapter/test fixture; it should not increase retry or fallback budgets without new approval.
