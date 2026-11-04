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

The submission is intentionally a contribution repository. Do not copy the original application into it. The supported judge path is:

```bash
git clone https://github.com/TheKeeper64bit/Tuka.-Meta-CerebralValley-Hackathon-.git
cd Tuka.-Meta-CerebralValley-Hackathon-
bash scripts/setup-judges.sh test
```

The script clones the public original repository, checks out the baseline, applies the event patch, restores event-created files and modes, and compares the resulting Git tree with `7273a0a`. It then installs the locked dependencies, runs the tests and builds the Meta assets. It refuses to overwrite an existing reconstruction directory; remove or rename `.reconstructed-tuka/` before repeating a fresh run.

For source-only verification use `bash scripts/setup-judges.sh verify`. For a local preview after `test`:

```bash
cd .reconstructed-tuka
npx wrangler dev --config wrangler.meta.jsonc --port 8793 --compatibility-date 2026-10-13
```

The compatibility-date flag is only for environments whose bundled `workerd` predates `2026-10-28`; the production configuration remains pinned to the event reference. The local Worker redirects unauthenticated `/` requests to `/login`. A valid local password is required for authenticated UI access.
## Automated judge setup

From a fresh checkout of this submission, run `bash scripts/setup-judges.sh test` (Git, Node.js 22+ and npm required). It fetches the original repository at the pinned baseline and pinned event commit, extracts the changes to pre-existing files, adds event-created files, verifies the exact resulting Git tree, runs `npm ci` and `npm test`, then builds the Meta version. The pinned integrated event commit remains an explicit source dependency. The setup script does not deploy the app or contact an AI provider. On November 4, 2026, a fresh-clone run passed exact tree reconstruction, 198 Node tests with zero failures, standalone regression checks, and the 65-asset Meta build. Live model inference remains unverified.
