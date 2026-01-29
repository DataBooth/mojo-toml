# Recipe Validation Setup - Quick Start

Your mojo-toml repo now has local validation tools that match modular-community CI exactly.

## ✅ What's Been Added

1. **Validation Script** - `scripts/validate-recipe.sh`
   - Runs rattler-build validation locally
   - Same checks as modular-community CI
   - Fast feedback before PR submission

2. **GitHub Actions** - `.github/workflows/validate-recipe.yml`
   - Auto-validates on push/PR
   - Shows results in Actions tab

3. **recipe.yaml** - Root-level recipe file
   - Validated schema (tests:, documentation:, repository:)
   - Mojo 0.25.7 with context variables
   - Ready for modular-community submission

4. **Documentation** - `docs/RECIPE_VALIDATION.md`
   - Complete validation guide
   - Common error reference
   - Integration examples

## 🚀 Usage

### Validate Locally (Before Committing)

```bash
cd /Users/mjboothaus/code/github/databooth/mojo-toml
./scripts/validate-recipe.sh recipe.yaml
```

**Expected output:**
```
✅ Recipe validation passed!
Your recipe.yaml follows the modular-community schema.
```

### Update Other Packages

Copy these files to your other packages:

```bash
# For each of: mojo-yaml, mojo-dotenv, mojo-ini, mojo-asciichart
cp scripts/validate-recipe.sh ../mojo-yaml/scripts/
cp .github/workflows/validate-recipe.yml ../mojo-yaml/.github/workflows/
cp docs/RECIPE_VALIDATION.md ../mojo-yaml/docs/

# Copy recipe from modular-community (already validated)
cp /path/to/modular-community/recipes/mojo-yaml/recipe.yaml ../mojo-yaml/
```

### Automated Validation

The GitHub Actions workflow runs automatically when `recipe.yaml` changes. View results at:
`https://github.com/DataBooth/mojo-toml/actions`

## 📋 Integration Options

### Option 1: Pre-commit Hook (Recommended)

Add to `.pre-commit-config.yaml`:

```yaml
  - repo: local
    hooks:
      - id: validate-recipe
        name: Validate recipe.yaml
        entry: ./scripts/validate-recipe.sh
        language: system
        files: ^recipe\.yaml$
        pass_filenames: false
```

Then: `pre-commit install`

### Option 2: Just Recipe

Add to `justfile`:

```just
validate-recipe:
    ./scripts/validate-recipe.sh recipe.yaml
```

Usage: `just validate-recipe`

### Option 3: Pixi Task

Add to `pixi.toml`:

```toml
[tasks]
validate-recipe = "./scripts/validate-recipe.sh recipe.yaml"
```

Usage: `pixi run validate-recipe`

## 🔄 Workflow

1. **Update recipe.yaml** - Make your changes
2. **Validate locally** - `./scripts/validate-recipe.sh recipe.yaml`
3. **Fix issues** - If validation fails
4. **Commit** - Once validation passes
5. **Submit PR** - To modular-community with confidence

## 🎯 Benefits

- ✅ **Catch errors early** - Before PR submission
- ✅ **Faster iteration** - No waiting for CI
- ✅ **Same validation** - Exact same tools as modular-community
- ✅ **Automated checks** - GitHub Actions integration
- ✅ **Clear feedback** - Helpful error messages

## 📚 More Info

See `docs/RECIPE_VALIDATION.md` for:
- Complete setup instructions
- Common schema errors reference
- Troubleshooting guide
- Advanced usage

## 🔗 Next Steps

1. Test validation: `./scripts/validate-recipe.sh recipe.yaml`
2. Add to pre-commit: Edit `.pre-commit-config.yaml`
3. Replicate to other packages: Copy files as shown above
4. Read full guide: `docs/RECIPE_VALIDATION.md`
