# Tuka. — Meta Cerebral Valley Hackathon 2026

**Hackathon contribution repository, not a copy of the pre-event application.**

The original Skopje Tuka. application predates the event. This repository contains newly introduced hackathon modules, tests, documentation, and a reproducible setup that assembles the full integrated app from an explicitly disclosed original dependency.

## Judge quick start

Requires **Git, Node.js 22+ and npm**, with internet access to fetch the public original repository and install dependencies.

```bash
git clone https://github.com/TheKeeper64bit/Tuka.-Meta-CerebralValley-Hackathon-.git
cd Tuka.-Meta-CerebralValley-Hackathon-
bash scripts/setup-judges.sh test
```

The command reconstructs the application into `.reconstructed-tuka/`, verifies its complete Git tree against the pinned integrated event commit, installs dependencies, runs tests, and builds the Meta site. Empty placeholder files in this repository are intentionally replaced by matching bytes and file modes from the pinned event reference. No secrets are required for source verification, but live AI inference requires separately supplied credentials.

For local preview after setup:

```bash
cd .reconstructed-tuka
npx wrangler dev --config wrangler.meta.jsonc --port 8793
```

If the installed local `workerd` predates the configured `2026-10-28` compatibility date, add `--compatibility-date 2026-10-13` for a local-only preview. This does not change the production configuration or the reconstruction tree.

Use `bash scripts/setup-judges.sh verify` for source reconstruction without installing dependencies. The script refuses to overwrite an existing `.reconstructed-tuka` directory; delete that directory manually before another fresh run. To start the preview automatically, use `bash scripts/setup-judges.sh dev` from a clean checkout.

## Dependency and provenance disclosure

- **Original Tuka baseline:** [`bd6e1e34df8066efcbacd6838d537e8a728ef002`](https://github.com/TheKeeper64bit/Tuka./commit/bd6e1e34df8066efcbacd6838d537e8a728ef002), October 17, 2026.
- **Pinned integrated hackathon reference:** [`7273a0a7efcd39d8b3bb1d18614d825f636153cd`](https://github.com/TheKeeper64bit/Tuka./commit/7273a0a7efcd39d8b3bb1d18614d825f636153cd), November 4, 2026.
- **Hackathon branch:** [`codex/meta-hackathon`](https://github.com/TheKeeper64bit/Tuka./tree/codex/meta-hackathon).
- **Live demo:** https://tuka.meta-cerebralvalley.rand0m.net

The setup fetches the separate original repository, checks out the pinned pre-event baseline, extracts **only modifications** to existing files between the two pinned commits, and adds files created during the event. For newly added files not bundled here (including generated feed artifacts), it retrieves them from the **pinned event commit**. The integrated event commit is thus also an explicit build-time dependency. No original pre-event application files are included in this submission.

The original app, its existing route planner, and pre-event Skopje functionality are not claimed as event work. Only contributions after the event cutoff are submitted for judging. Commit timestamps alone do not prove when each line was authored.

## What was developed during the event

Multi-city GTFS integration (including Boston and Tilburg), local GTFS ZIP importing, transit-specific AI tooling, localization, additional transit UI, ticket wallet functionality, and regression tests. See [HACKATHON_SCOPE.md](HACKATHON_SCOPE.md) and [REPRODUCE.md](REPRODUCE.md).

## Verification limits

The reproducible setup was executed from a fresh clone on November 4, 2026. The exact reconstruction tree matched `7273a0a`; the three Node test groups reported 100 + 64 + 34 = 198 passing tests and zero failures; and the Meta build produced 65 assets. A local Worker started with the compatibility-date override and returned the expected unauthenticated redirect to `/login`. Live provider-backed Meta/Baseten inference has **not** been independently verified; mocked provider tests do not prove live model operation. Imported feed and routing checks do not guarantee field accuracy.

The submitted code is evaluated as an event contribution built upon a disclosed, separate original application.
