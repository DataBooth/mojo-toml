# Recipe Validation for modular-community

This guide explains how to validate your `recipe.yaml` locally before submitting to modular-community, ensuring it passes CI on the first try.

## Why Validate Locally?

modular-community uses `rattler-build` to parse and build packages. Running the same validation locally catches schema errors before submission, saving time and iteration cycles.

## Setup

### Prerequisites

1. **pixi** - Package manager
   ```bash
   curl -fsSL https://pixi.sh/install.sh | bash
   ```

2. **rattler-build** - Recipe builder (installed automatically by script)
   ```bash
   pixi global install rattler-build
   ```

## Validation Methods

### Method 1: Local Script (Recommended)

Run the validation script from your package root:

```bash
./scripts/validate-recipe.sh recipe.yaml
```

This runs the exact same validation as modular-community CI in `--render-only` mode (no actual build).

**Example output:**
```
🔍 Validating recipe.yaml against modular-community schema...

🏗️  Running rattler-build validation...
✅ Recipe validation passed!

Your recipe.yaml follows the modular-community schema.
It should pass CI when submitted.
```

### Method 2: GitHub Actions (Automated)

The `.github/workflows/validate-recipe.yml` workflow runs automatically when you:
- Push changes to `recipe.yaml`
- Create a PR that modifies `recipe.yaml`

View results in the "Actions" tab of your repo.

### Method 3: Manual rattler-build

For advanced users who want full control:

```bash
pixi exec rattler-build build \
    --recipe recipe.yaml \
    --channel conda-forge \
    --channel https://conda.modular.com/max \
    --channel https://prefix.dev/modular-community \
    --render-only
```

## Common Schema Errors

### ❌ Wrong: Singular `test:`
```yaml
test:
  commands:
    - test -f $PREFIX/lib/mojo/package/__init__.mojo
```

### ✅ Correct: Plural `tests:` with `script:`
```yaml
tests:
  - script:
      - test -f $PREFIX/lib/mojo/package/__init__.mojo
```

---

### ❌ Wrong: `doc_url` and `dev_url`
```yaml
about:
  doc_url: https://github.com/user/package/blob/main/README.md
  dev_url: https://github.com/user/package
```

### ✅ Correct: `documentation` and `repository`
```yaml
about:
  documentation: https://github.com/user/package/blob/main/README.md
  repository: https://github.com/user/package
```

---

### ❌ Wrong: Missing `script:` in tests
```yaml
tests:
  - commands:  # Should be 'script:'
      - test -f $PREFIX/lib/mojo/package/__init__.mojo
```

### ✅ Correct: Proper test structure
```yaml
tests:
  - script:
      - test -f $PREFIX/lib/mojo/package/__init__.mojo
```

## Integration with Your Workflow

### Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: validate-recipe
        name: Validate recipe.yaml
        entry: ./scripts/validate-recipe.sh
        language: system
        files: ^recipe\.yaml$
        pass_filenames: false
```

Then install: `pre-commit install`

### Just Recipe

Add to `justfile`:

```just
# Validate recipe.yaml against modular-community schema
validate-recipe:
    ./scripts/validate-recipe.sh recipe.yaml
```

Usage: `just validate-recipe`

### Pixi Task

Add to `pixi.toml`:

```toml
[tasks]
validate-recipe = "./scripts/validate-recipe.sh recipe.yaml"
```

Usage: `pixi run validate-recipe`

## Troubleshooting

### "pixi not found"
Install pixi: `curl -fsSL https://pixi.sh/install.sh | bash`

### "rattler-build not found"
The script auto-installs it, or manually: `pixi global install rattler-build`

### Recipe fails validation
Read the error output carefully - it tells you exactly which line/field is problematic. Common issues:
- Field names (test vs tests, doc_url vs documentation)
- Missing `script:` section
- Incorrect YAML structure (indentation, list format)

### Need more details?
Run with verbose output:
```bash
RATTLER_BUILD_LOG=debug ./scripts/validate-recipe.sh recipe.yaml
```

## Reference

- [rattler-build docs](https://prefix-dev.github.io/rattler-build/)
- [modular-community schema examples](https://github.com/modular/modular-community/tree/main/recipes)
- [SUBMITTING_TO_MODULAR_COMMUNITY.md](SUBMITTING_TO_MODULAR_COMMUNITY.md)
