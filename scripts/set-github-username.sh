#!/usr/bin/env bash
# Mengganti placeholder YOUR_GITHUB_USERNAME di seluruh proyek dengan username GitHub Anda.
# Pemakaian: ./scripts/set-github-username.sh username-anda [folder-GameVaultCore]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Pemakaian: $0 <username-github> [path-ke-folder-GameVaultCore]"
  exit 1
fi

USERNAME="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGETS=("$ROOT")
if [[ $# -ge 2 ]]; then
  TARGETS+=("$(cd "$2" && pwd)")
fi

for dir in "${TARGETS[@]}"; do
  grep -rl "YOUR_GITHUB_USERNAME" "$dir" \
    --include="*.swift" --include="*.yml" --include="*.yaml" --include="*.md" --include="*.resolved" \
    --exclude-dir=".build" --exclude-dir=".git" | while read -r file; do
      sed -i '' "s/YOUR_GITHUB_USERNAME/${USERNAME}/g" "$file"
      echo "✔ $file"
    done
done

echo "Selesai. Jalankan 'xcodegen generate' lalu build ulang."
