#!/usr/bin/env bash
# Build recipe using rattler-build and verify package artifacts
#
# This script builds the conda package locally to verify:
# 1. Recipe renders correctly
# 2. Package builds without errors
# 3. Expected files are included in the package

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RECIPE_FILE="$PROJECT_ROOT/recipe.yaml"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${GREEN}INFO: $1${NC}"
}

warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check prerequisites
if ! command -v pixi &> /dev/null; then
    error "pixi is not installed. Install from https://pixi.sh"
fi

if ! pixi list | grep -q rattler-build; then
    error "rattler-build not found in pixi environment"
fi

# Ensure recipe exists
if [ ! -f "$RECIPE_FILE" ]; then
    error "Recipe file not found: $RECIPE_FILE"
fi

info "Building recipe: $RECIPE_FILE"

# Clean previous output
if [ -d "$OUTPUT_DIR" ]; then
    info "Cleaning previous output directory"
    rm -rf "$OUTPUT_DIR"
fi

# Build the package
info "Running rattler-build (tests disabled; tests are covered by pixi test-all)..."
if ! pixi exec rattler-build build \
    --recipe "$RECIPE_FILE" \
    --channel conda-forge \
    --channel https://conda.modular.com/max \
    --channel https://prefix.dev/modular-community \
    --output-dir "$OUTPUT_DIR" \
    --test skip; then
    error "rattler-build failed"
fi

# Verify output
if [ ! -d "$OUTPUT_DIR" ]; then
    error "Output directory not created: $OUTPUT_DIR"
fi

# Find the built package
PACKAGE_FILES=($(find "$OUTPUT_DIR" -name "*.conda" -o -name "*.tar.bz2" 2>/dev/null))

if [ ${#PACKAGE_FILES[@]} -eq 0 ]; then
    error "No package files found in $OUTPUT_DIR"
fi

info "Build successful!"
echo ""
info "Built packages:"
for pkg in "${PACKAGE_FILES[@]}"; do
    echo "  - $(basename "$pkg")"
done

echo ""
info "Package contents:"
for pkg in "${PACKAGE_FILES[@]}"; do
    echo "  Package: $(basename "$pkg")"
    if [[ "$pkg" == *.conda ]]; then
        # .conda files are zip archives containing tar.zst archives
        if command -v unzip &> /dev/null && command -v unzstd &> /dev/null; then
            # Extract and inspect the pkg-*.tar.zst
            TEMP_DIR=$(mktemp -d)
            cd "$TEMP_DIR"
            unzip -q "$pkg"
            for tarball in pkg-*.tar.zst; do
                if [ -f "$tarball" ]; then
                    tar --use-compress-program=unzstd -tf "$tarball" | grep -E "\.(mojo|mojopkg)$" | awk '{print "    " $0}'
                fi
            done
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
        else
            warning "unzip/unzstd not available, skipping contents listing"
        fi
    elif [[ "$pkg" == *.tar.bz2 ]]; then
        tar -tjf "$pkg" | grep -E "\.(mojo|mojopkg)$" | awk '{print "    " $0}' || warning "No .mojo/.mojopkg files found"
    fi
done

echo ""
info "To test installation, run:"
echo "  pixi create test-env"
echo "  pixi add --manifest-path test-env/pixi.toml --channel file://$OUTPUT_DIR mojo-toml"

exit 0
