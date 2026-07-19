#!/bin/zsh

set -euo pipefail

VERSION="${1:-0.1.0}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/.build/releases"
APP_BUNDLE="$OUTPUT_DIR/JingchengLedger.app"
ARCHIVE="$OUTPUT_DIR/JingchengLedger-v${VERSION}-macos-arm64.zip"
CHECKSUM="$ARCHIVE.sha256"
VERIFY_DIR="$OUTPUT_DIR/verify-v${VERSION}"

cd "$ROOT_DIR"

swift build -c release --jobs 4
BIN_DIR="$(swift build -c release --show-bin-path)"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

cp "$BIN_DIR/FushengjiMac" "$APP_BUNDLE/Contents/MacOS/FushengjiMac"
cp -R "$BIN_DIR/BeijingFushengjiMac_FushengjiCore.bundle" "$APP_BUNDLE/Contents/Resources/BeijingFushengjiMac_FushengjiCore.bundle"
cp "$ROOT_DIR/Packaging/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_BUNDLE/Contents/Info.plist"
chmod +x "$APP_BUNDLE/Contents/MacOS/FushengjiMac"

xattr -cr "$APP_BUNDLE"
codesign --force --deep --sign - "$APP_BUNDLE"
codesign --verify --deep --strict "$APP_BUNDLE"

rm -rf "$VERIFY_DIR"
rm -f "$ARCHIVE" "$CHECKSUM"
ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ARCHIVE"

mkdir -p "$VERIFY_DIR"
ditto -x -k "$ARCHIVE" "$VERIFY_DIR"
codesign --verify --deep --strict "$VERIFY_DIR/JingchengLedger.app"
rm -rf "$VERIFY_DIR"

cd "$OUTPUT_DIR"
shasum -a 256 "$(basename "$ARCHIVE")" > "$(basename "$CHECKSUM")"

echo "$ARCHIVE"
echo "$CHECKSUM"
