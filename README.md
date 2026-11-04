# Tuka. — Meta Cerebral Valley Hackathon 2026

**Hackathon-only contribution repository.** This is not a copy of the original Tuka application.

Tuka began as a Skopje public transport app before the event. During the hackathon it gained multi-city GTFS support, a universal local GTFS ZIP importer, transit-oriented AI integration, and additional tests and UI improvements.

- [Live hackathon demonstration](https://tuka.meta-cerebralvalley.rand0m.net)
- [Original Tuka project](https://github.com/TheKeeper64bit/Tuka.)
- [Integrated development branch](https://github.com/TheKeeper64bit/Tuka./tree/codex/meta-hackathon)
- [Contribution provenance](HACKATHON_SCOPE.md)
- [Reproduction instructions](REPRODUCE.md)

## Repository policy
Only files **newly introduced** on the hackathon branch after the October 17 baseline are included here, together with new submission documentation. Existing pre-event source files and their Git history are not copied. Files preserve their paths in the integrated application.

The original baseline is `bd6e1e34df8066efcbacd6838d537e8a728ef002`. The audited hackathon branch tip is `7273a0a7efcd39d8b3bb1d18614d825f636153cd`.

**This is not a standalone build.** The working demo depends on the pre-existing Tuka application and hackathon modifications to pre-existing files, which are deliberately excluded from this submission. Review the integrated branch and reproduction guide for those dependencies.

## Verified scope and limitations
- Wellington Metlink GTFS import demonstrated 3,123 stops, 245 routes and 10,080 trips; end-to-end journey accuracy there was not independently verified.
- The Network Inspector's deterministic checks and UI were tested. **Successful live provider-backed AI inference was not independently verified.** Mocked responses do not establish a real Meta API call.
- Original Skopje journey planning, routing, and UI predate the event and are not claimed as newly created.
- Large generated feed binaries are not included in this source-only extraction.

## Evaluation
Inspect the submitted modules and tests, consult [HACKATHON_SCOPE.md](HACKATHON_SCOPE.md) for the cutoff and omissions, and open the linked demo to evaluate the integrated product.