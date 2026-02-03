#!/bin/bash

# ============================================
# Version Bump Script for iOS
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# File paths
VERSION_FILE="$PROJECT_ROOT/version.txt"
PLIST_FILE="$PROJECT_ROOT/WebToNative/Info.plist"

# Get bump type
BUMP_TYPE="$1"

if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
  echo "❌ Invalid bump type: $BUMP_TYPE"
  echo "Usage: ./version-bump.sh [major|minor|patch]"
  exit 1
fi

# Read current version
if [ -f "$VERSION_FILE" ]; then
  VERSION=$(sed -n '1p' "$VERSION_FILE" | tr -d ' \r\n')
else
  VERSION="0.0.0"
fi

# Parse version
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

# Calculate new version
case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Version Bump: $VERSION → $NEW_VERSION ($BUMP_TYPE)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Update version.txt
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "✅ Updated version.txt"

# Update Info.plist
if [ -f "$PLIST_FILE" ]; then
  echo "📄 Updating: $PLIST_FILE"
  
  # Show current value
  echo "Before:"
  grep -A1 "PlatformVersion" "$PLIST_FILE" | grep string
  
  # Update PlatformVersion using PlistBuddy (macOS)
  if command -v /usr/libexec/PlistBuddy &> /dev/null; then
    /usr/libexec/PlistBuddy -c "Set :PlatformVersion $NEW_VERSION" "$PLIST_FILE"
  else
    # Fallback to sed for Linux/CI
    sed -i '' 's|<key>PlatformVersion</key>[\n\r\t ]*<string>[0-9]*\.[0-9]*\.[0-9]*</string>|<key>PlatformVersion</key>\
	<string>'"$NEW_VERSION"'</string>|' "$PLIST_FILE" 2>/dev/null || \
    sed -i 's|<key>PlatformVersion</key>\s*<string>[0-9]*\.[0-9]*\.[0-9]*</string>|<key>PlatformVersion</key>\n\t<string>'"$NEW_VERSION"'</string>|' "$PLIST_FILE"
  fi
  
  # Show updated value
  echo "After:"
  grep -A1 "PlatformVersion" "$PLIST_FILE" | grep string
  
  echo "✅ Updated Info.plist"
else
  echo "❌ Info.plist not found at: $PLIST_FILE"
  exit 1
fi

echo ""
echo "🎉 Version bump complete!"
echo ""