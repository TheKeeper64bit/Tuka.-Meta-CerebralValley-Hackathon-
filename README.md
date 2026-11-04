# Tuka. — Transit, made local.

**A map-first public transport companion, expanded for the Meta Cerebral Valley Hackathon 2026.**

[Live demo](https://tuka.meta-cerebralvalley.rand0m.net) · [Hackathon scope](HACKATHON_SCOPE.md) · [Reproduction guide](REPRODUCE.md) · [Original Tuka.](https://github.com/TheKeeper64bit/Tuka.)

> **A hackathon contribution repository, not a republication of the original app.** Tuka. began as a Skopje transit application before the event. This repository contains event contributions, tests, documentation, and a reproducible procedure for integrating them with the separately disclosed original codebase.

## Why Tuka.?

Transit information is fragmented across cities, operators, and data formats. Tuka. explores a more consistent experience: discover nearby stops on a map, inspect routes, plan journeys, and use transit-focused AI assistance without treating model-generated text as authoritative arrival data.

The hackathon work extends the Skopje foundation toward a **multi-city, GTFS-powered experience**, including Boston and Tilburg. Availability and accuracy depend on the underlying local feeds; a city being supported does not imply every route has real-time coverage.

## What the hackathon adds

- **Multi-city transit:** GTFS integration for additional cities, including Boston and Tilburg.
- **Bring your own feed:** local GTFS ZIP import functionality.
- **Journey assistance:** transit-scoped AI interpretation with strict, validated intent fields rather than invented route IDs, trips, coordinates, or arrival predictions.
- **Local-first experience:** localization, additional transit UI, and city-specific information.
- **More rider tools:** ticket-wallet functionality and regression coverage.

These are descriptions of the hackathon contributions, **not claims that all features have been end-to-end verified in every city**. See [HACKATHON_SCOPE.md](HACKATHON_SCOPE.md) for authorship boundaries.

## Judge quick start

**Requirements:** Git, Node.js 22+, npm, and internet access to retrieve the public original repository and install dependencies.

```bash
git clone https://github.com/TheKeeper64bit/Tuka.-Meta-CerebralValley-Hackathon-.git
cd Tuka.-Meta-CerebralValley-Hackathon-
bash scripts/setup-judges.sh test
```

This reconstructs the integrated application in `.reconstructed-tuka/`, verifies the pinned event tree, applies the reviewable post-event compatibility patch, installs dependencies, runs tests, and builds the Meta site. **No AI API key is needed to reproduce the source or run the automated tests.** The setup does not deploy the app or make paid model requests.

For a local preview after setup:

```bash
cd .reconstructed-tuka
npx wrangler dev --config wrangler.meta.jsonc --port 8793
```

If your local `workerd` is older than the configured compatibility date, add `--compatibility-date 2026-10-13` to that preview command. This is a local-only override, not a change to production settings. The app redirects unauthenticated visitors to `/login`; testing authenticated pages requires a locally configured authorized password. **Never commit credentials or put them in a public issue.** Live AI inference additionally requires valid provider credentials and a supported model.

Other setup modes:

- `bash scripts/setup-judges.sh verify` — reconstruct and verify source without installing dependencies.
- `bash scripts/setup-judges.sh dev` — start the development preview from a clean checkout.

The script intentionally refuses to overwrite an existing `.reconstructed-tuka/` directory. Remove or rename it before repeating a fresh reconstruction. For full details, read [REPRODUCE.md](REPRODUCE.md).

## Verification — November 4, 2026

| Check | Outcome |
| --- | --- |
| Fresh reconstruction and pinned-tree verification | **Passed** |
| Post-event compatibility patch application | **Passed** |
| Existing Node tests | **198 passed** |
| Structured-tool compatibility regression tests | **9 passed** |
| Meta production build | **Passed — 65 assets** |
| Authenticated local login and application assets | **Passed** |
| Baseten live journey interpretation | **Passed — HTTP 200; canonical intent validated** |
| Direct Meta live journey interpretation | **Not verified as usable — HTTP 502 on the bounded retest** |
| GitHub Actions on final audit commit | **Passed** |

The successful Baseten test produced an intent with the canonical fields `date`, `destination`, `maxWalkingMinutes`, `mode`, `origin`, `preference`, and `time`. The application accepted it through its strict validator. This verifies **intent interpretation**, not the accuracy of a subsequently planned journey or real-time arrival prediction.

The direct Meta endpoint remains a documented limitation. Do not interpret successful authentication or mocked tests as proof that direct Meta inference works. No automatic retries or fallback calls were used in the bounded live retest.

Evidence: [Live authentication and provider checks](reports/live-ai-auth-verification-2026-11-04.md) · [Compatibility fix and final retest](reports/provider-compatibility-fix-2026-11-04.md) · [Final CI run](https://github.com/TheKeeper64bit/Tuka.-Meta-CerebralValley-Hackathon-/actions/runs/41874610271).

## Provenance and what is being judged

The **original Skopje application predates the hackathon**. It is a separately fetched dependency, not work claimed as new for the event.

| Reference | Pinned commit |
| --- | --- |
| [Pre-event baseline](https://github.com/TheKeeper64bit/Tuka./commit/bd6e1e34df8066efcbacd6838d537e8a728ef002) | `bd6e1e34df8066efcbacd6838d537e8a728ef002` |
| [Integrated event reference](https://github.com/TheKeeper64bit/Tuka./commit/7273a0a7efcd39d8b3bb1d18614d825f636153cd) | `7273a0a7efcd39d8b3bb1d18614d825f636153cd` |

The setup fetches the public original repository, checks out the baseline, reconstructs modifications to pre-existing files and files introduced during the event, restores missing event-created artifacts from the **pinned integrated event commit**, and verifies the resulting Git tree. It then applies the separately reviewable `patches/provider-tool-compat.patch` for the post-event provider compatibility fix. The pinned integrated event reference therefore remains an **explicit build-time dependency**; the compatibility patch is not represented as part of the pinned event tree.

Original Skopje functionality, its existing planner, and pre-event source are **not claimed as hackathon work**. The integrated reference and patch are disclosed so judges can inspect the exact boundary. Reproducibility does **not** constitute organizer approval of eligibility, and commit timestamps alone cannot prove when every line was authored.

See [HACKATHON_SCOPE.md](HACKATHON_SCOPE.md) and [REPRODUCE.md](REPRODUCE.md) for the detailed disclosure and reconstruction procedure.

---

**Tuka.** One familiar way to find your way around a new city.
