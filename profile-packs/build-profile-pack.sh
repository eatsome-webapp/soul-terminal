#!/bin/bash
set -euo pipefail

# Arguments
PROFILE_ID="${1:?Usage: build-profile-pack.sh <profile-id>}"
VERSION_TAG="${2:?Usage: build-profile-pack.sh <profile-id> <version-tag>}"

# Paths
STAGING_PREFIX="/data/data/com.soul.terminal/files/usr"
BASE_SNAPSHOT="/tmp/base-snapshot.txt"
OUTPUT_DIR="/output"

echo "=== Building profile pack: $PROFILE_ID version $VERSION_TAG ==="

# Step 1: Snapshot base $PREFIX state (file listing with timestamps)
find "$STAGING_PREFIX" -type f -o -type l | sort > "$BASE_SNAPSHOT"
touch /tmp/timestamp-marker

# Step 2: Install packages based on profile
case "$PROFILE_ID" in
  claude-code)
    apt-get update
    apt-get install -y nodejs git gh
    npm install -g @anthropic-ai/claude-code
    ;;
  python)
    apt-get update
    apt-get install -y python python-pip git
    ;;
  *)
    echo "ERROR: Unknown profile: $PROFILE_ID"
    exit 1
    ;;
esac

# Step 3: Find new/modified files (delta)
DELTA_DIR="/tmp/profile-delta"
mkdir -p "$DELTA_DIR"

# Files newer than our timestamp marker
find "$STAGING_PREFIX" -newer /tmp/timestamp-marker -type f | while IFS= read -r filepath; do
  rel="${filepath#$STAGING_PREFIX/}"
  mkdir -p "$DELTA_DIR/$(dirname "$rel")"
  cp "$filepath" "$DELTA_DIR/$rel"
done

# Step 4: Build SYMLINKS.txt from new symlinks
find "$STAGING_PREFIX" -newer /tmp/timestamp-marker -type l | while IFS= read -r lnk; do
  target=$(readlink "$lnk")
  rel="${lnk#$STAGING_PREFIX/}"
  echo "${target}←${rel}"
done > "$DELTA_DIR/SYMLINKS.txt"

# Handle case where no new symlinks exist (empty file is fine)

# Step 5: Create zip
PACK_FILENAME="profile-pack-${PROFILE_ID}-aarch64.zip"
cd "$DELTA_DIR"
zip -r "$OUTPUT_DIR/$PACK_FILENAME" . -x "*.pyc"

# Step 6: Strip unnecessary files to reduce size
# Remove docs, man pages, __pycache__, .map files from the zip
zip -d "$OUTPUT_DIR/$PACK_FILENAME" "share/doc/*" "share/man/*" "**/__pycache__/*" "**.map" 2>/dev/null || true

# Step 7: Compute SHA-256
SHA256=$(sha256sum "$OUTPUT_DIR/$PACK_FILENAME" | cut -d' ' -f1)
SIZE_BYTES=$(stat -c%s "$OUTPUT_DIR/$PACK_FILENAME")

echo "=== Build complete ==="
echo "FILE: $PACK_FILENAME"
echo "SHA256: $SHA256"
echo "SIZE: $SIZE_BYTES bytes"

# Write metadata for workflow consumption
cat > "$OUTPUT_DIR/metadata.json" << EOF
{
  "profile_id": "$PROFILE_ID",
  "version": "$VERSION_TAG",
  "sha256": "$SHA256",
  "size_bytes": $SIZE_BYTES,
  "filename": "$PACK_FILENAME"
}
EOF
