#!/usr/bin/env bash
# Validate packaging/recipe.yaml against modular-community schema
# This runs the same validation as modular-community CI

set -euo pipefail

RECIPE_FILE="${1:-packaging/recipe.yaml}"

echo "🔍 Validating ${RECIPE_FILE} against modular-community schema..."
echo ""

# Check if pixi is installed
if ! command -v pixi &> /dev/null; then
    echo "❌ pixi not found. Install with: curl -fsSL https://pixi.sh/install.sh | bash"
    exit 1
fi

# Check if rattler-build is available
if ! pixi global list | grep -q rattler-build; then
    echo "📦 Installing rattler-build..."
    pixi global install rattler-build
fi

# Validate recipe (render-only mode - no actual build)
echo "🏗️  Running rattler-build validation..."
pixi exec rattler-build build \
    --recipe "${RECIPE_FILE}" \
    --channel conda-forge \
    --channel https://conda.modular.com/max \
    --channel https://prefix.dev/modular-community \
    --render-only

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Recipe validation passed!"
    echo ""
    echo "Your recipe file follows the modular-community schema."
    echo "It should pass CI when submitted."
else
    echo "❌ Recipe validation failed!"
    echo ""
    echo "Common issues:"
    echo "  - Use 'tests:' (plural) not 'test:'"
    echo "  - Use 'documentation:' not 'doc_url'"
    echo "  - Use 'repository:' not 'dev_url'"
    echo "  - Tests need 'script:' section under list item"
    echo ""
    echo "Fix these issues before submitting to modular-community."
fi

exit $EXIT_CODE
