#!/usr/bin/env bash
# Comprehensive pre-submission validation checklist
#
# This script performs all validation steps required before submitting
# to modular-community:
# 1. Run full test suite
# 2. Validate recipe schema
# 3. Build package with rattler-build
# 4. Verify git tag exists and matches recipe version
# 5. Verify package installs and works

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RECIPE_FILE="$PROJECT_ROOT/recipe.yaml"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Tracking
CHECKS_PASSED=0
CHECKS_FAILED=0
FAILED_CHECKS=()

error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${BLUE}→ $1${NC}"
}

section() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_passed() {
    ((CHECKS_PASSED++))
    success "$1"
}

check_failed() {
    ((CHECKS_FAILED++))
    FAILED_CHECKS+=("$1")
    error "$1"
}

# Change to project root
cd "$PROJECT_ROOT"

# Print header
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║         Pre-Submission Validation Checklist                  ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# CHECK 1: Full test suite
# ============================================================================
section "CHECK 1: Running full test suite"

if pixi run test-all; then
    check_passed "All tests pass"
else
    check_failed "Tests failed"
fi

# ============================================================================
# CHECK 2: Recipe schema validation
# ============================================================================
section "CHECK 2: Validating recipe schema"

if [ ! -f "$RECIPE_FILE" ]; then
    check_failed "Recipe file not found: $RECIPE_FILE"
else
    if bash "$SCRIPT_DIR/validate-recipe.sh"; then
        check_passed "Recipe schema is valid"
    else
        check_failed "Recipe validation failed"
    fi
fi

# ============================================================================
# CHECK 3: Build package
# ============================================================================
section "CHECK 3: Building package with rattler-build"

if bash "$SCRIPT_DIR/build-recipe.sh"; then
    check_passed "Package builds successfully"

    # Verify package files exist
    PACKAGE_FILES=($(find "$OUTPUT_DIR" -name "*.conda" -o -name "*.tar.bz2" 2>/dev/null || true))
    if [ ${#PACKAGE_FILES[@]} -gt 0 ]; then
        check_passed "Package artifacts created: ${#PACKAGE_FILES[@]} file(s)"
    else
        check_failed "No package artifacts found"
    fi
else
    check_failed "Package build failed"
fi

# ============================================================================
# CHECK 4: Git tag verification
# ============================================================================
section "CHECK 4: Verifying git tag"

# Extract version from recipe.yaml
if [ -f "$RECIPE_FILE" ]; then
    RECIPE_VERSION=$(grep "^  version:" "$RECIPE_FILE" | awk '{print $2}' | tr -d '"' | tr -d "'")

    if [ -z "$RECIPE_VERSION" ]; then
        check_failed "Could not extract version from recipe.yaml"
    else
        info "Recipe version: $RECIPE_VERSION"

        # Check if tag exists
        if git tag | grep -q "^v${RECIPE_VERSION}$"; then
            check_passed "Git tag v${RECIPE_VERSION} exists"

            # Check if tag points to HEAD
            TAG_COMMIT=$(git rev-list -n 1 "v${RECIPE_VERSION}")
            HEAD_COMMIT=$(git rev-parse HEAD)

            if [ "$TAG_COMMIT" = "$HEAD_COMMIT" ]; then
                check_passed "Tag v${RECIPE_VERSION} points to HEAD"
            else
                check_failed "Tag v${RECIPE_VERSION} does not point to HEAD (tag: ${TAG_COMMIT:0:8}, HEAD: ${HEAD_COMMIT:0:8})"
            fi
        else
            check_failed "Git tag v${RECIPE_VERSION} does not exist"
            info "Create tag with: git tag -a v${RECIPE_VERSION} -m \"Release v${RECIPE_VERSION}\""
        fi
    fi
fi

# ============================================================================
# CHECK 5: Package installation test
# ============================================================================
section "CHECK 5: Testing package installation"

# Create temporary test environment
TEST_ENV_DIR=$(mktemp -d)
TEST_PROJECT="$TEST_ENV_DIR/test-install"

info "Creating test environment at $TEST_PROJECT"

if pixi init "$TEST_PROJECT" >/dev/null 2>&1; then
    # Try to add the local package
    if pixi add \
        --manifest-path "$TEST_PROJECT/pixi.toml" \
        --channel "file://$OUTPUT_DIR" \
        --channel conda-forge \
        --channel https://conda.modular.com/max \
        --channel https://prefix.dev/modular-community \
        mojo-toml >/dev/null 2>&1; then
        check_passed "Package installs successfully"

        # Verify files are present
        PACKAGE_NAME=$(basename "$PROJECT_ROOT")
        if [ -d "$TEST_PROJECT/.pixi/envs/default/lib/mojo/$PACKAGE_NAME" ]; then
            check_passed "Package files installed correctly"
        else
            check_failed "Package files not found in environment"
        fi
    else
        check_failed "Package installation failed"
    fi
else
    check_failed "Failed to create test environment"
fi

# Cleanup
rm -rf "$TEST_ENV_DIR"

# ============================================================================
# Summary
# ============================================================================
section "SUMMARY"

echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║  ✓ ALL CHECKS PASSED ($CHECKS_PASSED/$((CHECKS_PASSED + CHECKS_FAILED)))                                    ║${NC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓ Package is ready for submission to modular-community${NC}"
    echo ""
    info "Next steps:"
    echo "  1. Push tag: git push origin v${RECIPE_VERSION}"
    echo "  2. Update recipe in modular-community PR"
    echo "  3. Push updated recipe to trigger CI"
    echo ""
    exit 0
else
    echo -e "${BOLD}${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${RED}║  ✗ CHECKS FAILED ($CHECKS_FAILED/$((CHECKS_PASSED + CHECKS_FAILED)))                                       ║${NC}"
    echo -e "${BOLD}${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Failed checks:${NC}"
    for check in "${FAILED_CHECKS[@]}"; do
        echo -e "${RED}  - $check${NC}"
    done
    echo ""
    echo -e "${YELLOW}⚠ Fix issues before submitting to modular-community${NC}"
    echo ""
    exit 1
fi
