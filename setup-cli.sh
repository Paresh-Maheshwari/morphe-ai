#!/bin/bash
# setup-cli.sh — Install or update Morphe Desktop
# Two modes: download release (default) or build from source
set -e

SYMLINK="$(dirname "$0")/morphe-desktop.jar"
REPO="MorpheApp/morphe-desktop"

# --- Mode: Download latest release ---
download_release() {
    echo "📦 Fetching latest morphe-desktop release..."
    
    # Get latest version from GitHub API
    LATEST=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
    
    if [ -z "$LATEST" ]; then
        echo "❌ Failed to fetch latest version from GitHub"
        exit 1
    fi
    
    VERSION="${LATEST#v}"  # Remove 'v' prefix
    
    # Check if current version matches
    if [ -f "$SYMLINK" ]; then
        CURRENT=$(java -jar "$SYMLINK" --version 2>/dev/null | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ "$CURRENT" = "$VERSION" ]; then
            echo "✅ Already up to date (v${VERSION})"
            exit 0
        fi
        echo "   Current: v${CURRENT:-unknown} → Latest: v${VERSION}"
    fi
    
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST}/morphe-desktop-${VERSION}-all.jar"
    echo "   Downloading v${VERSION}..."
    
    curl -L -o "$SYMLINK" "$DOWNLOAD_URL"
    chmod +x "$SYMLINK"
    echo "✅ morphe-desktop v${VERSION} ready: $SYMLINK"
}

# --- Mode: Build from source ---
build_from_source() {
    CLI_DIR="$(dirname "$0")/MorpheApp/morphe-desktop"
    if [ ! -d "$CLI_DIR" ]; then
        echo "❌ Source not found at $CLI_DIR"
        echo "   Clone it: git clone https://github.com/${REPO} MorpheApp/morphe-desktop"
        exit 1
    fi
    cd "$CLI_DIR"
    echo "🔧 Building morphe-desktop from source..."
    git pull
    VER=$(grep "^version" gradle.properties | cut -d= -f2 | tr -d ' ')
    ./gradlew build
    JAR=$(find build/libs -name "*-all.jar" | head -1)
    ln -sf "$(pwd)/$JAR" "$SYMLINK"
    echo "✅ morphe-desktop v${VER} ready: $SYMLINK"
}

# --- Main ---
case "${1:-download}" in
    download|d)  download_release ;;
    build|b)     build_from_source ;;
    *)
        echo "Usage: ./setup-cli.sh [download|build]"
        echo "  download  — Download latest release from GitHub (default)"
        echo "  build     — Build from source (requires MorpheApp/morphe-desktop)"
        ;;
esac
