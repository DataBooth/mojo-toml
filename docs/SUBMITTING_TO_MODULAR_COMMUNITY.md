# Guide: Submitting a Package to Modular Community

A comprehensive guide for submitting Mojo packages to the modular-community channel, based on real experience submitting DataBooth/mojo-toml.

**Official documentation**: https://www.modular.com/community/package-submission

## Overview

The modular-community channel allows you to distribute your Mojo packages so they can be installed via `pixi add` by anyone in the community. Packages are built using `rattler-build` and distributed through the MAX Builds platform.

## Prerequisites

### 1. Your Package Repository Setup

Before submitting, ensure your package has:

- ✅ **Git tags for releases** (e.g., `v0.9.1`)
- ✅ **LICENSE file** in repository root
- ✅ **README.md** with clear documentation
- ✅ **Tests** that can be run to verify the package works
- ✅ **Clear project structure** with source code in a consistent location (e.g., `src/packagename/`)

### 2. Security & Quality Requirements

- ✅ **Enable CodeQL scanning** in your repository
  - Go to Settings → Security → Code scanning → Set up → Choose "Default"
  - Add CodeQL badge to README: `[![CodeQL](https://github.com/USER/REPO/workflows/CodeQL/badge.svg)](https://github.com/USER/REPO/actions/workflows/codeql.yml)`
- ✅ **Package image** for builds.modular.com display (512×512 PNG, named `image.png`)
- ✅ **Tests pass** on all target platforms (macOS, Linux)

### 3. Local Development Tools

Install required tools:
```bash
# GitHub CLI (for PR management)
brew install gh
gh auth login

# Fork and clone the modular-community repository
gh repo fork modular/modular-community --clone
cd modular-community
```

## Step-by-Step Submission Process

### Step 1: Create Your Recipe Branch

```bash
cd /path/to/modular-community

# Fetch latest changes
git fetch origin
git checkout main
git pull origin main

# Create a new branch for your package
git checkout -b add-YOURPACKAGE-v0.1.0
```

**Naming convention**: `add-YOURPACKAGE-vX.Y.Z` (e.g., `add-mojo-toml-v0.9.1`)

### Step 2: Create Recipe Directory Structure

```bash
mkdir -p recipes/YOURPACKAGE
cd recipes/YOURPACKAGE
```

Your recipe directory should contain:
- `recipe.yaml` - Package recipe (required)
- `test_package.mojo` - Test file (required)
- `image.png` - Logo/icon for builds.modular.com (512×512 PNG)

### Step 3: Create `recipe.yaml`

Use this template and customize for your package:

```yaml
package:
  name: mojo-toml
  version: 0.9.1

source:
  git: https://github.com/DataBooth/mojo-toml.git
  tag: v0.9.1  # Git tag in your repo

build:
  number: 0  # Increment for same version, reset to 0 for new version
  script:
    # Copy source files to PREFIX location
    - mkdir -p $PREFIX/lib/mojo/toml
    - cp -r src/toml/* $PREFIX/lib/mojo/toml/

requirements:
  build:
    - mojo-compiler =1.0.0b1
  host:
    - mojo-compiler =1.0.0b1
  run:
    - ${{ pin_compatible('mojo-compiler') }}

tests:
  - script:
      # Verify files were installed correctly
      - test -f $PREFIX/lib/mojo/toml/__init__.mojo
      - test -f $PREFIX/lib/mojo/toml/parser.mojo

about:
  homepage: https://github.com/DataBooth/mojo-toml
  license: Apache-2.0  # Use SPDX identifier
  license_file: LICENSE
  summary: Native TOML 1.0 parser and writer for Mojo - Complete + Partial 1.1 🔥
  description: |
    mojo-toml is a native TOML 1.0 parser and writer for Mojo, enabling
    fast and efficient parsing and writing of TOML configuration files with zero
    Python dependencies.

    Features:
    - Complete TOML 1.0 specification support
    - TOML writer with full round-trip fidelity
    - 168 comprehensive tests (100% passing)
    - Zero Python dependencies
  documentation: https://github.com/DataBooth/mojo-toml/blob/main/README.md
  repository: https://github.com/DataBooth/mojo-toml

extra:
  recipe-maintainers:
    - mjboothaus  # Your GitHub username
```

#### Key Fields Explained

**Context Variables** (optional but recommended):
```yaml
context:
  version: "0.9.1"
  
package:
  version: ${{ version }}  # Reference context variable
```

**Source Section**:
- Use `tag:` for stable releases (recommended)
- Use `rev:` for specific commit SHA if needed
- The tag/rev must exist in your GitHub repository

**Build Number**:
- Start at `0` for first submission of a version
- Increment for recipe fixes without version change
- Reset to `0` when version changes

**Build Script**:
- Use `$PREFIX` environment variable for install location
- Standard path: `$PREFIX/lib/mojo/PACKAGENAME/`
- For `.mojopkg` files: `$PREFIX/lib/mojo/PACKAGENAME.mojopkg`

**Requirements**:
- `build`: Tools needed during build
- `host`: Runtime dependencies for building
- `run`: Runtime dependencies for users
- Use `${{ pin_compatible('mojo-compiler') }}` to lock Mojo compiler compatibility

**Test Commands**:
- Verify installed files exist
- Run basic smoke tests
- Keep tests quick (< 30 seconds)

**License**:
- Must use SPDX identifier (see https://spdx.org/licenses/)
- Common: `MIT`, `Apache-2.0`, `BSD-3-Clause`, `GPL-3.0-only`

### Step 4: Create `test_package.mojo`

Create a test file that verifies your package works:

```mojo
"""Test that mojo-toml package is installed and functional."""

from toml import parse

fn main() raises:
    # Test basic parsing
    var toml_str = """
    title = "Test"
    count = 42
    enabled = true
    """
    
    var data = parse(toml_str)
    
    # Verify parsed correctly
    var title = data["title"].as_string()
    var count = data["count"].as_int()
    var enabled = data["enabled"].as_bool()
    
    # Basic assertions
    if title != "Test":
        raise Error("Title parsing failed")
    if count != 42:
        raise Error("Integer parsing failed")
    if not enabled:
        raise Error("Boolean parsing failed")
    
    print("✓ All tests passed")
```

### Step 5: Create Package Image

Create a 512×512 PNG logo named `image.png`:

```bash
# If you have an existing logo
cp /path/to/your/logo.png recipes/YOURPACKAGE/image.png

# Or create a simple one with Python/PIL
python3 << 'EOF'
from PIL import Image, ImageDraw, ImageFont

size = (512, 512)
img = Image.new('RGB', size, color='#1E1E1E')
draw = ImageDraw.Draw(img)

# Draw your logo design here
# ... (customize as needed)

img.save('recipes/YOURPACKAGE/image.png')
print("✓ Created image.png")
EOF
```

The image will be displayed on builds.modular.com when your package is featured.

### Step 6: Commit and Push

```bash
# Add all recipe files
git add recipes/YOURPACKAGE/

# Commit with descriptive message
git commit -m "Add YOURPACKAGE v0.1.0 - Brief description

- Package description
- Key features
- Any relevant notes"

# Push to your fork
git push origin add-YOURPACKAGE-v0.1.0
```

### Step 7: Create Pull Request

Using GitHub CLI:

```bash
# Create PR body file
cat > /tmp/pr_body.md << 'EOF'
Adds YOURPACKAGE v0.1.0 - Brief description of your package.

**Package features:**
- Feature 1
- Feature 2
- Feature 3

**Testing:**
- ✅ Tests pass locally
- ✅ CodeQL scanning enabled
- ✅ Package image included

Repository: https://github.com/YOU/YOURPACKAGE
EOF

# Create the PR
gh pr create \
  --repo modular/modular-community \
  --base main \
  --head YOURUSERNAME:add-YOURPACKAGE-v0.1.0 \
  --title "Add YOURPACKAGE v0.1.0 - Brief description" \
  --body-file /tmp/pr_body.md
```

## Updating Your Package

### For New Version (e.g., 0.9.0 → 0.9.1)

```bash
cd modular-community
git checkout main
git pull origin main

# Create new branch for updated version
git checkout -b add-YOURPACKAGE-v0.9.1

# Update recipe.yaml
# - Change package.version to 0.9.1
# - Change source.tag to v0.9.1 (or appropriate tag)
# - Reset build.number to 0

git add recipes/YOURPACKAGE/recipe.yaml
git commit -m "Update YOURPACKAGE to v0.9.1"
git push origin add-YOURPACKAGE-v0.9.1

# Create new PR
gh pr create --repo modular/modular-community ...
```

### For Recipe Fix (same version)

```bash
# Make changes to recipe.yaml
# Increment build.number (e.g., 0 → 1)

git add recipes/YOURPACKAGE/recipe.yaml
git commit -m "Fix YOURPACKAGE recipe: description of fix"
git push origin add-YOURPACKAGE-v0.9.1
```

## Common Issues & Solutions

### Issue: PR not showing package image

**Problem**: Old PR branch may be cached by GitHub.

**Solution**: Create fresh PR with new branch name
```bash
git checkout -b add-YOURPACKAGE-vX.Y.Z-v2  # Add suffix
git push origin add-YOURPACKAGE-vX.Y.Z-v2
# Close old PR and create new one
```

### Issue: Tests failing in CI

**Problem**: Package not found or test errors.

**Solution**: 
1. Check `test_package.mojo` imports match installed paths
2. Verify build script copies files correctly
3. Test locally with `pixi` if possible

### Issue: Build number confusion

**Problem**: When to increment build number vs version?

**Solution**:
- **New version** (0.9.0 → 0.9.1): Reset `build.number` to `0`
- **Recipe fix** (same 0.9.1): Increment `build.number` (0 → 1 → 2)
- **New PR for same version**: Usually keep `build.number` at `0`

### Issue: License identifier unclear

**Problem**: "MIT License" vs "MIT"?

**Solution**: Always use SPDX identifier from https://spdx.org/licenses/
- ✅ `MIT`
- ✅ `Apache-2.0`
- ✅ `BSD-3-Clause`
- ❌ `MIT License`
- ❌ `Apache 2.0`

## PR Review Process

After submitting your PR:

1. **Automated checks** will run (CI tests, lint checks)
2. **Reviewer will check**:
   - Recipe format is correct
   - Tests pass on all platforms
   - Package image is present
   - License is properly specified
   - Security requirements met (CodeQL)
3. **Address feedback** if needed:
   ```bash
   # Make changes locally
   git add recipes/YOURPACKAGE/
   git commit -m "Address review feedback: specific change"
   git push origin add-YOURPACKAGE-vX.Y.Z
   # PR updates automatically
   ```
4. **Merge**: Once approved, maintainers will merge your PR

## After Merge

Your package will be available via:
```bash
pixi add YOURPACKAGE
```

Users can then import and use it in their Mojo projects!

## Best Practices

### Version Management
- Use semantic versioning (X.Y.Z)
- Tag releases in your repository before submitting
- Keep recipe version in sync with git tag

### Documentation
- Include clear README.md in your repository
- Add usage examples
- Document any platform-specific requirements

### Testing
- Test on both macOS and Linux if possible
- Include tests that verify core functionality
- Keep tests fast (< 30 seconds total)

### Maintenance
- Respond promptly to PR feedback
- Monitor your package's issues on modular-community
- Update package when dependencies change

## Checklist

Before submitting, verify:

- [ ] Git tag exists for version (e.g., `v0.9.1`)
- [ ] LICENSE file in repository
- [ ] CodeQL scanning enabled
- [ ] CodeQL badge in README
- [ ] `recipe.yaml` created with all required fields
- [ ] `test_package.mojo` verifies basic functionality
- [ ] `image.png` (512×512) included
- [ ] License uses SPDX identifier
- [ ] Build script installs to `$PREFIX/lib/mojo/PACKAGENAME/`
- [ ] Tests pass locally
- [ ] Branch name follows convention: `add-PACKAGENAME-vX.Y.Z`
- [ ] PR title and description are clear

## Resources

- **Official guide**: https://www.modular.com/community/package-submission
- **rattler-build docs**: https://prefix-dev.github.io/rattler-build/
- **SPDX licenses**: https://spdx.org/licenses/
- **Modular forum**: https://forum.modular.com/
- **Discord**: Join #package-submission channel

## Example Packages

Reference these for examples:
- **mojo-toml**: https://github.com/DataBooth/mojo-toml
- **hue**: https://github.com/thatstoasty/hue
- Browse recipes: https://github.com/modular/modular-community/tree/main/recipes

## Getting Help

- **Forum**: https://forum.modular.com/ (package-submitter topic)
- **Discord**: #package-submission channel
- **Email**: caroline@modular.com (@caroline_frasca)

---

*This guide is based on the experience of submitting mojo-toml v0.9.1 to modular-community in January 2026.*

## Lessons Learned & Best Practices

### ✅ Recipe Schema Requirements (Critical!)

**Issue:** Recipe parser is strict about field names and structure.

**Required schema (not optional):**
```yaml
# ❌ WRONG - Will fail CI
test:
  commands:
    - test -f $PREFIX/lib/mojo/package/__init__.mojo

about:
  doc_url: https://github.com/user/package/blob/main/README.md
  dev_url: https://github.com/user/package

# ✅ CORRECT - Will pass CI  
tests:
  - script:
      - test -f $PREFIX/lib/mojo/package/__init__.mojo

about:
  documentation: https://github.com/user/package/blob/main/README.md
  repository: https://github.com/user/package
```

**Key differences:**
- Use `tests:` (plural) not `test:`
- Use `script:` block, not `commands:`
- Tests must be a list (note the `-` before `script:`)
- Use `documentation:` not `doc_url`
- Use `repository:` not `dev_url`

**Prevention:** Use local validation (see next section)

### ✅ Local Validation Setup

**Problem:** Schema errors aren't caught until CI runs, wasting time.

**Solution:** Validate locally before submission.

**Setup in your package repo:**

1. Add validation script: [`scripts/validate-recipe.sh`](../scripts/validate-recipe.sh)
2. Add GitHub Actions: [`.github/workflows/validate-recipe.yml`](../.github/workflows/validate-recipe.yml)
3. Add to pre-commit:
   ```yaml
   - repo: local
     hooks:
       - id: validate-recipe
         name: Validate recipe.yaml schema
         entry: ./scripts/validate-recipe.sh
         language: system
         files: ^packaging/recipe\\.yaml$
         pass_filenames: false
   ```

**Usage:**
```bash
./scripts/validate-recipe.sh packaging/recipe.yaml
```

See [RECIPE_VALIDATION.md](RECIPE_VALIDATION.md) for complete setup guide.

### ✅ Mojo Version Management

**Best practice:** Use context variables for version management.

**Recommended pattern:**
```yaml
context:
  version: 0.9.1
  mojo_version: "=1.0.0b1"  # Current migration target

package:
  name: mojo-package
  version: ${{ version }}

requirements:
  build:
    - mojo-compiler ${{ mojo_version }}
  host:
    - mojo-compiler ${{ mojo_version }}
  run:
    - ${{ pin_compatible('mojo-compiler') }}
```

**Benefits:**
- Single place to update Mojo version
- `pin_compatible()` allows compatible patch/minor updates within your selected compiler series
- Clear which version was tested

**When to update:** When new stable Mojo releases (check [Mojo changelog](https://docs.modular.com/mojo/changelog/))

### ✅ Pre-commit Hygiene

**Issue:** Trailing whitespace, incorrect line endings cause CI failures.

**Solution:** Install and run pre-commit in your package repos.

**Setup:**
```bash
cd your-package-repo
pixi run bash -c "pre-commit install"
pixi run bash -c "pre-commit run --all-files"
```

**Common fixes pre-commit catches:**
- Trailing whitespace
- Missing final newlines
- YAML/TOML syntax errors
- Mixed line endings

**Automate:** Pre-commit runs on every `git commit` once installed.

### ✅ Git Tag Management

**Critical:** Recipe `tag:` field must match an actual git tag in your repo.

**Common mistake:**
```yaml
package:
  version: 0.9.1

source:
  tag: v0.9.0  # ❌ Version mismatch!
```

**Correct approach:**
```bash
# 1. Make sure tag exists
git tag v0.9.1
git push --tags

# 2. Then reference it in recipe
source:
  tag: v0.9.1  # ✅ Matches package version
```

**Workflow:**
1. Commit all changes
2. Create and push git tag: `git tag -a v0.9.1 -m "v0.9.1 - Description" && git push --tags`
3. Update recipe.yaml with matching version/tag
4. Submit PR to modular-community

### ✅ Platform Considerations

**Your packages are likely cross-platform:**

If your package:
- ✅ Ships pure Mojo source code
- ✅ Has no platform-specific dependencies
- ✅ Doesn't compile binaries during install

**Consider adding:**
```yaml
build:
  number: 0
  noarch: generic  # Single build for all platforms
```

**Benefits:**
- 3x faster CI (one build vs. three)
- ~66% less storage
- Faster user installs

**When NOT to use `noarch`:**
- Building `.mojopkg` files (platform-specific binaries)
- Using platform-specific tools in build script
- Running compiled tests

See [PLATFORM_BUILDS.md](PLATFORM_BUILDS.md) for details.

### ✅ PR Workflow Tips

**After submitting PR:**

1. **CI needs approval** - First-time contributors need maintainer approval to run workflows
2. **Be patient** - CI runs take 5-15 minutes across 3 platforms
3. **Watch for feedback** - Reviewers may request changes (schema, tests, documentation)
4. **Update efficiently** - Fix issues, commit, push to same branch (PR auto-updates)

**Common review requests:**
- Add package image
- Enable CodeQL scanning
- Fix recipe schema (tests:, documentation:, repository:)
- Update license to Apache-2.0 (if applicable)
- Add missing test files

**Iteration workflow:**
```bash
# 1. Fix locally first
./scripts/validate-recipe.sh packaging/recipe.yaml

# 2. Commit changes
git add recipes/your-package/
git commit -m "Address review feedback: fix schema"

# 3. Push (PR updates automatically)
git push origin add-your-package-v0.1.0
```

## Checklist Before Submission

Use this checklist before creating your PR:

**Your Package Repo:**
- [ ] Git tag exists and pushed (e.g., `v0.9.1`)
- [ ] CodeQL enabled with badge in README
- [ ] Pre-commit hooks installed and passing
- [ ] Tests pass locally
- [ ] LICENSE file exists
- [ ] Package image created (512×512 PNG)

**Recipe Files:**
- [ ] `packaging/recipe.yaml` validates locally (`./scripts/validate-recipe.sh packaging/recipe.yaml`)
- [ ] Uses `tests:` (plural) with `script:` block
- [ ] Uses `documentation:` and `repository:` (not `doc_url`/`dev_url`)
- [ ] `tag:` matches package `version:`
- [ ] `test_package.mojo` exists and tests core functionality
- [ ] `image.png` exists (512×512 PNG)

**PR Quality:**
- [ ] Branch name: `add-PACKAGE-vX.Y.Z`
- [ ] PR title clear: "Add package-name vX.Y.Z"
- [ ] PR description includes features, use case, compliance checklist
- [ ] All files committed and pushed

## Resources

**Official:**
- [Modular Community Package Submission](https://www.modular.com/community/package-submission)
- [rattler-build Documentation](https://prefix-dev.github.io/rattler-build/)
- [Mojo Changelog](https://docs.modular.com/mojo/changelog/)

**Package-Specific:**
- [RECIPE_VALIDATION.md](RECIPE_VALIDATION.md) - Local validation setup
- [PLATFORM_BUILDS.md](PLATFORM_BUILDS.md) - Cross-platform considerations
- [ROADMAP.md](planning/ROADMAP.md) - Future improvements (noarch, etc.)

**Community:**
- [modular-community GitHub](https://github.com/modular/modular-community)
- [Mojo Discord](https://discord.gg/modular)

---

**Document version:** 2.0  
**Last updated:** 2026-01-29  
**Maintainer:** @mjboothaus
