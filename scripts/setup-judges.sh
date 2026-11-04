#!/usr/bin/env bash
set -Eeuo pipefail

# Reproduce the hackathon integration without vendoring pre-event Tuka source.
# Requires git, Node.js >=22 and npm. Does not deploy or contact an AI provider.
BASE="bd6e1e34df8066efcbacd6838d537e8a728ef002"
EVENT="7273a0a7efcd39d8b3bb1d18614d825f636153cd"
UPSTREAM="${TUKA_UPSTREAM:-https://github.com/TheKeeper64bit/Tuka.}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${TUKA_BUILD_DIR:-$ROOT/.reconstructed-tuka}"
MODE="${1:-setup}"
if [[ "$MODE" != setup && "$MODE" != test && "$MODE" != dev && "$MODE" != verify ]]; then
  echo "Usage: bash scripts/setup-judges.sh [setup|verify|test|dev]" >&2; exit 2
fi
command -v git >/dev/null
command -v node >/dev/null
command -v npm >/dev/null
node -e 'if (+process.versions.node.split(".")[0] < 22) process.exit(1)' || { echo 'Node 22+ required' >&2; exit 2; }
if [[ -e "$TARGET" ]]; then
  echo "Refusing to overwrite existing build directory: $TARGET" >&2
  echo "Remove it manually to reproduce from scratch." >&2; exit 2
fi
mkdir -p "$(dirname "$TARGET")"
git clone --no-checkout "$UPSTREAM" "$TARGET"
cd "$TARGET"
git fetch origin "$BASE" "$EVENT"
git cat-file -e "$BASE^{commit}"
git cat-file -e "$EVENT^{commit}"
git checkout --detach "$BASE"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Extract only changes to pre-existing files from the pinned hackathon ref.
# The patch is generated at setup time, never committed as pre-event source.
git diff --binary --diff-filter=M "$BASE" "$EVENT" > "$TMP/modified-files.patch"
git apply --check "$TMP/modified-files.patch"
git apply --binary "$TMP/modified-files.patch"

# Restore files newly introduced by the event. Prefer files in the submission
# repository; use the pinned event ref for missing generated/large artifacts.
git diff --name-only --diff-filter=A "$BASE" "$EVENT" > "$TMP/new-files.txt"
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  mkdir -p "$(dirname "$path")"
  # Empty tracked placeholders are deliberately not treated as submitted
  # artifacts. This lets the repository keep a reviewable file list while
  # fetching binary/generated files from the pinned event ref.
  if [[ -s "$ROOT/$path" ]]; then
    cp "$ROOT/$path" "$path"
    actual="$(git hash-object "$path")"
    expected="$(git rev-parse "$EVENT:$path")"
    if [[ "$actual" != "$expected" ]]; then
      echo "Submission file differs from pinned hackathon source: $path" >&2; exit 1
    fi
  else
    git show "$EVENT:$path" > "$path"
    echo "Pinned upstream event artifact (not bundled): $path"
  fi
  # Preserve the mode recorded in the pinned event tree as well as the bytes.
  # Git applies content patches but does not infer the mode for newly restored
  # files created by a shell redirection.
  mode="$(git ls-tree "$EVENT" -- "$path" | awk '{print $1}')"
  case "$mode" in
    100755) chmod +x "$path" ;;
    100644) chmod -x "$path" ;;
    *) echo "Unsupported mode $mode for $path" >&2; exit 1 ;;
  esac
  git add -f -- "$path"
done < "$TMP/new-files.txt"

# Compare full reconstructed tree to the integrated commit, including binaries.
git add -A
actual="$(git write-tree)"
expected="$(git rev-parse "$EVENT^{tree}")"
echo "Reconstructed tree: $actual"
echo "Expected event tree: $expected"
if [[ "$actual" != "$expected" ]]; then
  echo 'FAIL: reconstructed tree differs from the pinned hackathon commit' >&2
  git diff --cached --stat "$EVENT" >&2 || true
  exit 1
fi
echo 'PASS: exact source reconstruction'
if [[ "$MODE" == verify ]]; then exit 0; fi
npm ci
if [[ "$MODE" == test ]]; then npm test; fi
npm run build:meta
echo "Ready: $TARGET"
if [[ "$MODE" == dev ]]; then
  echo 'Starting local development server (AI provider credentials optional).'
  npx wrangler dev --config wrangler.meta.jsonc --port 8793
else
  echo "For local preview: cd '$TARGET' && npx wrangler dev --config wrangler.meta.jsonc --port 8793"
fi
