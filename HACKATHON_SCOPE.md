# Scope, authorship and provenance

**Event cutoff:** October 26, 2026.

Original project: [TheKeeper64bit/Tuka.](https://github.com/TheKeeper64bit/Tuka.)

- Pre-event baseline: `bd6e1e34df8066efcbacd6838d537e8a728ef002` (October 17, 2026).
- First post-baseline commit on the hackathon branch: `cd622b1214...` (October 28, 2026).
- Last audited hackathon commit: `7273a0a7efcd39d8b3bb1d18614d825f636153cd` (November 4, 2026).
- 28 commits ahead of the baseline. Commit timestamps alone do not independently establish the original authorship date of every line.

## What is included
Files added on `codex/meta-hackathon` relative to the October 17 baseline, preserving their original paths, and newly written submission documentation. These are the hackathon contribution, not a republication of the old application.

## What is excluded
Original Skopje app source, existing transit planner, UI, build files and infrastructure; modifications to files that existed before the event; generated binary datasets. The original application is referenced as a dependency, not included as source.

## Disclosure
This contribution repository intentionally does not vendor pre-event source. To reproduce the full integrated application, run the judge setup in REPRODUCE.md. The setup extracts modified-file patches from the pinned upstream event reference, restores event-created artifacts, verifies the exact integrated tree, and then runs the application tests and build. That fresh reconstruction passed on November 4, 2026 with 198 Node tests passing and zero failures. The original repository remains a separate dependency.

The AI Inspector's provider integrations were tested with mocks; a live Meta/Baseten inference was not independently verified. The submission makes no claim of organizer certification or guaranteed compliance.
