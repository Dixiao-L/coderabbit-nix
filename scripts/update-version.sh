#!/usr/bin/env bash
# Script to manually update CodeRabbit version
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/../package.nix"

# Get current version
CURRENT_VERSION=$(grep 'version = "' "$PACKAGE_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')
echo "Current version: $CURRENT_VERSION"

# Get latest version
LATEST_VERSION=$(curl -sL https://cli.coderabbit.ai/releases/latest/VERSION | tr -d '[:space:]')
echo "Latest version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

echo "Updating from $CURRENT_VERSION to $LATEST_VERSION..."

# Update version
sed -i "s/version = \"[^\"]*\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_NIX"

# Calculate new hash for x86_64-linux
echo "Calculating hash for x86_64-linux..."
NEW_HASH_X64=$(nix-prefetch-url "https://cli.coderabbit.ai/releases/$LATEST_VERSION/coderabbit-linux-x64.zip" 2>/dev/null)
echo "x86_64-linux hash: $NEW_HASH_X64"

# Update the first sha256 (x86_64-linux)
sed -i "0,/sha256 = \"[^\"]*\"/s/sha256 = \"[^\"]*\"/sha256 = \"$NEW_HASH_X64\"/" "$PACKAGE_NIX"

echo ""
echo "Updated package.nix to version $LATEST_VERSION"
echo ""
echo "Note: Only x86_64-linux hash was updated automatically."
echo "For other platforms, update the hashes manually or set to lib.fakeHash and let Nix report the correct hash."
echo ""
echo "To verify the build:"
echo "  nix build .#coderabbit"
