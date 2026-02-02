# Pixi workspace and pre-submit conventions

This document describes how pixi and the pre-submit pipeline are configured for this package. The same structure is shared across the `mojo-*` libraries so behaviour is predictable.

## Workspace configuration

- `platforms = ["linux-64", "linux-aarch64", "osx-arm64"]`
- `channels = ["conda-forge", "https://conda.modular.com/max"]`
- `name = "mojo-*"` (per-repository)
- `MOJO_PATH` is set via activation to `$PIXI_PROJECT_ROOT/src` so `mojo -I src` works consistently.

## Core tasks

### Development

- `mojo-version` – prints the Mojo compiler version available in the pixi environment.

### Tests

- `test-all` runs `python scripts/run_tests.py`.
- The Python runner:
  - auto-discovers `tests/test_*.mojo` files,
  - runs each with `mojo -I src`, and
  - reports a summary at the end.

Individual `test-*` tasks may exist for focused development, but `test-all` is the canonical entry point and is what pre-submit uses.

### Build

- `build-package` runs `mojo package` to produce a `.mojopkg` artefact under `dist/`.
- `clean` removes build and test artefacts (`dist`, `__pycache__`, `.pytest_cache`, and the local `.mojopkg` file).

### Code quality

- `pre-commit` – runs all pre-commit hooks for this repository.
- `pre-commit-install` – installs the git hooks for local development.

### Pre-submit for modular-community

There are two equivalent tasks:

- `pre-submit`
- `pre-submit-modular-community`

Both run `python scripts/pre_submit_checklist.py`, which performs:

1. **Tests** – `pixi run test-all` for the full test suite.
2. **Recipe validation** – `./scripts/validate-recipe.sh recipe.yaml` against the modular-community schema.
3. **Package build** – `./scripts/build-recipe.sh`, using `rattler-build` with tests disabled (tests are already covered by `test-all`).
4. **Git tag check** – ensures a `v<version>` tag exists and matches `HEAD`.
5. **Install check** – creates a temporary pixi project, adds a file:// channel pointing at `output/`, and verifies that the built package can be installed and that the expected files appear under `.pixi/envs/default/lib/mojo`.
6. **Optional modular-community build** – when invoked with `--modular-community` (or when the environment is configured accordingly), runs `pixi run build-all` in a local clone of the `modular-community` repository to mirror CI behaviour.

The script prints a summary of all checks and a short list of next steps (push tag, update modular-community recipe, trigger CI) when everything passes.

## Core dependencies

The shared core dependencies across the `mojo-*` libraries are:

- `max` – the Modular toolchain (`">=25.7.0,<26"`).
- `python` – used for the test runner, benchmarks, and pre-submit tooling (`">=3.11,<4"`).
- `pre-commit` – for local code quality checks (`">=4.5.1,<5"`).
- `rattler-build` – for building conda packages (`">=0.55.1,<0.56"`).

Each repository may add extra dependencies (for example benchmark counterparts such as `asciichartpy`, `python-dotenv`, `pyyaml`, or `tomli-w`) but the core tooling above is consistent.

## Relationship to modular-community

- The `pre-submit` / `pre-submit-modular-community` task is designed as a local analogue of the modular-community CI pipeline.
- A successful run means:
  - tests pass,
  - the recipe is structurally valid,
  - the package can be built locally with `rattler-build`,
  - the git tag and version are aligned, and
  - the built artefact can be installed into a fresh environment.
- When the optional modular-community step is enabled, the same `build-all` pipeline that CI uses will be exercised locally, reducing surprises when opening or updating a recipe PR.

This document should stay in sync with the `pixi.toml` and `scripts/pre_submit_checklist.py` files; when those change in a material way, please update this file as part of the same change set.
