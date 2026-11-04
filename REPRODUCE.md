# Reproduction and dependency disclosure

The new repository deliberately contains no pre-hackathon application source. The working demo is built on the original Tuka application.

**Original baseline:** `bd6e1e34df8066efcbacd6838d537e8a728ef002` (October 17, 2026).

**Integrated hackathon reference:** `7273a0a7efcd39d8b3bb1d18614d825f636153cd` (November 4, 2026).

To inspect the original foundation separately:

```bash
git clone https://github.com/TheKeeper64bit/Tuka. original-tuka
cd original-tuka
git checkout bd6e1e34df8066efcbacd6838d537e8a728ef002
```

To inspect the complete integrated hackathon state, **including the pre-existing dependency**:

```bash
git fetch origin codex/meta-hackathon
git checkout 7273a0a7efcd39d8b3bb1d18614d825f636153cd
npm ci
npm test
node scripts/build-meta.mjs
```

The integrated development branch includes pre-event code, and must not be pushed wholesale into this hackathon submission repository. These commands are an inspection recipe, not a claim that this submission alone is a standalone application. The complete reconstruction has not been independently tested in this extraction.