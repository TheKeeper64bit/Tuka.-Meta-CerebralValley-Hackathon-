#!/usr/bin/env bash
set -Eeuo pipefail
BASE=bd6e1e34df8066efcbacd6838d537e8a728ef002
HEAD=7273a0a7efcd39d8b3bb1d18614d825f636153cd
SOURCE="${SOURCE_REPO:-https://github.com/TheKeeper64bit/Tuka.}"
ROOT="$(pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$ROOT/reports/reconstruction"
git clone --no-checkout "$SOURCE" "$TMP/original"
cd "$TMP/original"
git fetch origin "$BASE" "$HEAD" codex/meta-hackathon
git cat-file -e "$BASE^{commit}"
git cat-file -e "$HEAD^{commit}"
git diff --name-status "$BASE" "$HEAD" > "$ROOT/reports/reconstruction/changed-files.tsv"
git diff --binary --unified=0 "$BASE" "$HEAD" > "$TMP/changes.patch"
# The generated patch is temporary, never committed to the contribution repository.
git checkout --detach "$BASE"
git apply --check "$TMP/changes.patch"
git apply --binary "$TMP/changes.patch"
git add -A
ACTUAL="$(git write-tree)"
EXPECTED="$(git rev-parse "$HEAD^{tree}")"
printf 'Baseline: %s\nTarget: %s\nReconstructed tree: %s\nExpected tree: %s\n' "$BASE" "$HEAD" "$ACTUAL" "$EXPECTED" | tee "$ROOT/reports/reconstruction/result.txt"
test "$ACTUAL" = "$EXPECTED" || { echo 'FAIL: reconstructed tree differs from target'; exit 1; }
echo 'PASS: reconstructed tree matches integrated hackathon commit' | tee -a "$ROOT/reports/reconstruction/result.txt"
npm ci
npm test
node scripts/build-meta.mjs
echo 'PASS: dependency install, tests and Meta build' | tee -a "$ROOT/reports/reconstruction/result.txt"
