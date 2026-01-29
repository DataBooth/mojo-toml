# Pre-Submission Validation

This document describes the comprehensive validation infrastructure to ensure packages are ready for submission to modular-community.

## Overview

Before submitting a package to modular-community, we must ensure:
1. ✅ All tests pass on both Linux and macOS
2. ✅ Recipe validates (schema correctness)
3. ✅ Recipe builds successfully with rattler-build
4. ✅ Built package installs and works correctly
5. ✅ Git tag exists and matches recipe version

## Validation Tools

### 1. Local Build Script (`scripts/build-recipe.sh`)

Builds the conda package locally using rattler-build:

```bash
bash scripts/build-recipe.sh
```

**What it does:**
- Cleans previous output directory
- Builds package with rattler-build
- Verifies package artifacts are created
- Lists package contents (shows .mojo files included)
- Provides instructions for testing installation

**Output location:** `output/` directory (git-ignored)

### 2. Pre-Submit Checklist (`scripts/pre-submit-checklist.sh`)

Comprehensive validation script that runs all 5 checks:

```bash
bash scripts/pre-submit-checklist.sh
```

**Checks performed:**

1. **Full test suite** - Runs `pixi run test-all` (137 tests across 16 suites)
2. **Recipe schema validation** - Runs `scripts/validate-recipe.sh`
3. **Package build** - Runs `scripts/build-recipe.sh` and verifies artifacts
4. **Git tag verification** - Checks if tag exists and points to HEAD
5. **Package installation test** - Creates temporary environment and installs package

**Exit codes:**
- `0` - All checks passed, ready for submission
- `1` - One or more checks failed (see output for details)

**Example output:**
```
╔══════════════════════════════════════════════════════════════╗
║         Pre-Submission Validation Checklist                  ║
╚══════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CHECK 1: Running full test suite
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ All tests pass

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CHECK 2: Validating recipe schema
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Recipe schema is valid

... (checks 3-5) ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

╔══════════════════════════════════════════════════════════════╗
║  ✓ ALL CHECKS PASSED (10/10)                                 ║
╚══════════════════════════════════════════════════════════════╝

✓ Package is ready for submission to modular-community

→ Next steps:
  1. Push tag: git push origin vX.Y.Z
  2. Update recipe in modular-community PR
  3. Push updated recipe to trigger CI
```

### 3. GitHub Actions Workflow (`.github/workflows/pre-submit-validation.yml`)

Automated validation that runs on every push affecting:
- `recipe.yaml`
- `src/**`
- `tests/**`
- `scripts/**`
- The workflow file itself

**What it does:**
- Runs on both `ubuntu-latest` and `macos-latest`
- Executes all 5 validation checks
- Uploads build artifacts for inspection
- Creates workflow summary

**Workflow steps:**
1. Checkout code (with full history for tag checking)
2. Setup pixi environment
3. Run full test suite
4. Validate recipe schema
5. Build package with rattler-build
6. Verify package artifacts
7. Check git tag (warning if missing, not failure)
8. Test package installation
9. Upload build artifacts

## Pre-Submission Checklist

Before submitting to modular-community, follow these steps:

### Step 1: Update Version
```bash
# Update version in recipe.yaml
vim recipe.yaml  # Change context.version

# Update CHANGELOG.md
vim CHANGELOG.md
```

### Step 2: Run Local Validation
```bash
bash scripts/pre-submit-checklist.sh
```

**All checks must pass** before proceeding.

### Step 3: Create and Push Git Tag
```bash
# Create annotated tag
git tag -a v0.X.Y -m "Release v0.X.Y"

# Push tag to GitHub
git push origin v0.X.Y
```

### Step 4: Verify GitHub Actions
```bash
# Check workflow status
gh run list --limit 5

# Watch specific workflow run
gh run watch
```

Wait for **both** Linux and macOS runs to pass.

### Step 5: Update modular-community PR

Update the recipe in your modular-community PR:
```bash
cd ../modular-community
git checkout your-branch
cp ../mojo-toml/recipe.yaml recipes/mojo-toml/recipe.yaml
git add recipes/mojo-toml/recipe.yaml
git commit -m "Update mojo-toml to vX.Y.Z

- Full description of changes

Co-Authored-By: Warp <agent@warp.dev>"
git push
```

### Step 6: Monitor modular-community CI

The modular-community CI will:
1. Validate recipe schema
2. Build package on Linux and macOS
3. Run test commands (verify files installed)
4. Check package metadata

## Troubleshooting

### Build Fails Locally

**Problem:** `rattler-build not found in pixi environment`

**Solution:** Ensure rattler-build is installed:
```bash
pixi add rattler-build
```

### Package Installation Fails

**Problem:** Package files not found after installation

**Solution:** Check recipe.yaml `files.include` section matches your source structure:
```yaml
files:
  include:
    - src/**/*.mojo
  exclude:
    - "**/__pycache__"
    - "**/*.pyc"
```

### Git Tag Doesn't Match Recipe Version

**Problem:** Tag v0.5.1 doesn't exist for recipe version 0.5.1

**Solution:** Create the tag:
```bash
git tag -a v0.5.1 -m "Release v0.5.1"
git push origin v0.5.1
```

### Tests Pass Locally but Fail in CI

**Problem:** Tests timeout or fail on macOS/Linux in CI

**Solution:**
1. Check if it's a transient CI issue (re-run workflow)
2. Verify tests pass on both platforms locally
3. Check for platform-specific dependencies
4. Review test timeout settings

## Continuous Improvement

This validation infrastructure prevents the following issues:

❌ **Before:** Only validated recipe schema, packages could fail to build
✅ **After:** Actually builds packages and tests installation

❌ **Before:** Could submit recipes referencing non-existent git tags
✅ **After:** Verifies tag exists and points to correct commit

❌ **Before:** Tests might not run on both platforms before submission
✅ **After:** CI validates on both Linux and macOS

## Related Documentation

- [`RECIPE_VALIDATION.md`](RECIPE_VALIDATION.md) - Recipe schema validation details
- [`PLATFORM_BUILDS.md`](PLATFORM_BUILDS.md) - Platform-specific build notes
- [`SUBMITTING_TO_MODULAR_COMMUNITY.md`](../SUBMITTING_TO_MODULAR_COMMUNITY.md) - Full submission guide
- [`ROADMAP.md`](../ROADMAP.md) - Future improvements (noarch: generic)
