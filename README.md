# Tuka. — Transit, made local.

**A map-first public transport companion, expanded for the Meta Cerebral Valley Hackathon 2026.**

[Live demo](https://tuka.meta-cerebralvalley.rand0m.net) · [Hackathon scope](HACKATHON_SCOPE.md) · [Reproduction guide](REPRODUCE.md) · [Original Tuka.](https://github.com/TheKeeper64bit/Tuka.)

> **A hackathon contribution repository, not a republication of the original app.** Tuka. began as a Skopje transit application before the event. This repository contains event contributions, tests, documentation, and a reproducible procedure for integrating them with the separately disclosed original codebase.

## The problem we're solving

Public transport should not require learning a different app in every city. Timetables, stops, live updates, route geometry, languages, and operator notices vary between networks. Riders still ask the same questions: **Where do I board? Which bus should I take? Will I make my connection? Can I arrive by a specific time?**

Tuka. began before the event as a **map-first Skopje bus app** with stop information, arrivals, and a journey planner. **The hackathon contribution was to turn that city-specific foundation into a reusable transit experience**: connect different networks, import compatible timetables, and let riders describe a trip naturally while the routing engine—not an AI model—determines actual journeys.

## What we built during the hackathon

### 1. One interface, different transit networks

We introduced a shared city-provider architecture so the same map, stops, routes, and journey-planning interface can use different cities' timetable data. **Boston** and **Tilburg** were added alongside the existing **Skopje** experience.

- A rider selects a supported city or lets location help choose it.
- Tuka loads that network's stops, routes, schedules, and available live-data adapters.
- City-specific time zones, service calendars, saved information, and asynchronous requests are kept aligned with the selected network.
- Switching cities changes the underlying transit data, not just the city name displayed on screen.

**Why it matters:** the user learns one transit interface instead of starting from scratch in every city. Published schedules remain useful when real-time coverage is missing.

### 2. Bring your own city with a GTFS ZIP

The universal importer makes the concept more than a three-city demo. A rider can choose **Import a network**, select a compatible **GTFS Schedule ZIP**, review the feed, and open its stops and routes in Tuka. **No new city-specific application code is required for a compatible schedule feed.**

Under the hood, a browser worker validates and normalizes the schedule, derives agencies and coverage, and stores imported timetable data locally using IndexedDB. The existing map, route explorer, departures, and planner then consume that normalized network.

**Demonstrated beyond the three built-in cities:** Wellington's public Metlink feed was imported, and the app displayed the imported network on the map without a Wellington-specific implementation. The reported import contained **3,123 stops, 245 routes, 10,080 trips, and 22 agencies**. This establishes import and visualization—not independently verified Wellington journey accuracy.

**Limits:** the importer handles compatible fixed-route GTFS Schedule ZIPs, not automatic real-time feeds, fares, operator news, or ticket integrations. Current limits are 50 MB compressed / 200 MB expanded.

### 3. Real transit data for Boston and Tilburg

Adding a city means more than drawing pins. The hackathon work included ingestion pipelines that preserve route identities, stop sequences, calendar rules, departure times, and published route shapes.

| Network | Hackathon work |
| --- | --- |
| **Skopje** | Existing foundation adapted to the shared multi-city experience |
| **Boston** | Official MBTA bus/shuttle schedules and GTFS-Realtime integration |
| **Tilburg region** | Regional bus dataset extracted from a much larger Netherlands feed, with full selected trips retained even when they travel beyond the initial region |

The Tilburg ingestion audit compared **407,058 stop calls across 16,873 trips** and reported zero mismatches in the compared identifiers, stop order, times, and boarding restrictions. This is **data-integrity evidence**, not a promise that every bus operates exactly on schedule.

Where available, real-time updates are matched against the underlying network using identifiers and freshness checks. Unmatched or stale updates should not silently become predictions.

### 4. Ask for a journey in natural language

We added a transit-focused Copilot integration that converts a rider's request into **structured planner inputs**.

For example:

> Get me to Tilburg Centraal tomorrow by 9:00, with no more than ten minutes of walking.

The intended flow is:

```text
Rider describes a trip
        ↓
Meta / Baseten model interprets the request
        ↓
Strict server validation of places, date, time,
preference, mode and walking limit
        ↓
Rider reviews or resolves ambiguous inputs
        ↓
Tuka's timetable-based journey planner finds routes
        ↓
Journey options, transfers and paths appear on the map
```

**The important engineering boundary:** AI interprets the rider's intent; it does **not** invent routes, trips, stop coordinates, departure predictions, or a completed itinerary. Those are resolved using transit data and the existing routing engine.

The provider gateway supports Meta and Baseten, with server-side credentials, bounded requests, validation, and controlled fallback. **Baseten successfully returned a live, schema-validated journey intent** in the final test. Direct Meta inference returned HTTP 502 and is not claimed as live working. A valid interpreted intent does not itself prove that a subsequent real-world journey is correct.

### 5. Plan a trip even when you're already on the bus

The hackathon Journey tab added an **onboard starting mode**. Instead of pretending every journey begins at a bus stop on foot, a rider can identify their current line, direction, and next stop. The planner can then compare remaining aboard against changing services later in the journey.

The journey interface also supports leaving now, leaving later, or arriving by a deadline, with preferences such as fewer transfers or less walking. This builds on the **pre-existing journey planner** rather than claiming that the entire routing engine was written during the hackathon.

### 6. A more local, understandable experience

The expansion included:

- **Language support:** English, Macedonian, Albanian, and Dutch in the hackathon interface.
- **Local service notices:** Tilburg operator notices, with an English-reading option that retains the original and labels machine-generated translation.
- **Map and route improvements:** published route geometry, directional variants, stop-to-shape matching, and explicit handling of approximations.
- **Rider continuity:** city-aware saved stops, places, and preferences; journey/ride guidance and additional ticket-wallet functionality.
- **Installable experience:** a PWA-style app that retains the familiar interface when switching supported networks.

Some capabilities depend on each city's data sources. Importing a GTFS schedule does **not** automatically enable live arrivals, notices, or ticket purchasing.

## What a judge can try

1. **Switch cities:** open Skopje, Boston, and Tilburg and observe the network data change inside the same interface.
2. **Explore a stop:** select a stop, inspect its routes and upcoming departures, and follow a route overlay.
3. **Plan a journey:** choose a destination, set an arrive-by time, and inspect the proposed route and transfers.
4. **Try onboard planning:** select a bus line, direction, and next stop to start from an ongoing ride.
5. **Inspect the AI handoff:** enter a natural-language transit request and review the validated planner fields. This requires working provider credentials.
6. **Import another network:** select a compatible GTFS Schedule ZIP and review the network before opening it.

The live demo may require authorized login credentials. Network coverage, live notices, and model availability vary. The documented source reconstruction is the reproducible path for judges who want to inspect the implementation.

## What is new, and what was already there?

| Before the hackathon | Added or extended during the hackathon |
| --- | --- |
| Skopje map-first bus experience | Shared city-provider architecture for additional networks |
| Existing stop, route, and arrival features | Boston and Tilburg data ingestion and realtime adapters |
| Existing journey-planning engine | Onboard journey entry, city-aware planning, and AI-to-planner handoff |
| Skopje-specific app experience | Generic GTFS ZIP importer and local schedule storage |
| Existing app foundation and UI | Localization, notices, multi-city UI adaptations, tests, and verification |

**Only the event-era additions and modifications are presented as hackathon work.** The original application remains a separately disclosed dependency, and the post-event provider compatibility patch is separately identified in the provenance section below.

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
