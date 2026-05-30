# mojo-toml migration notes: moving towards Mojo 1.0.0b1
This post captures the first migration tranche for `mojo-toml`: aligning packaging/tooling and modernising standard-library imports so the repository is easier to keep compatible on the 1.0 beta line.

## Why this migration was started
The project had started moving to a 1.0-era toolchain, but some repository flows were still mixed between old and new conventions. The main risks were:
- hidden CI/local breakage due to inconsistent recipe path assumptions,
- ongoing migration friction across sibling `mojo-*` repositories,
- stale docs and hooks teaching contributors the wrong command flow.

## What was changed in this tranche
### 1) Canonical recipe path and flow
We standardised on `packaging/recipe.yaml` as the single recipe source and aligned the operational paths around it:
- `pixi.toml` task `validate-recipe`,
- `scripts/validate-recipe.sh`,
- `scripts/build-recipe.sh`,
- `scripts/pre_submit_checklist.py`,
- `.github/workflows/pre-submit-validation.yml`,
- `.github/workflows/validate-recipe.yml`,
- `.pre-commit-config.yaml`,
- docs that describe validation and pre-submit.

### 2) Mojo stdlib import modernisation
We migrated maintained `.mojo` files from legacy imports to `std.*` paths:
- `from collections import ...` → `from std.collections import ...`
- `from pathlib import Path` → `from std.pathlib import Path`

Applied across core modules, key tests, examples, benchmarks, and dev helper tests.

### 3) Documentation alignment
We updated migration-sensitive docs to reflect the current packaging layout and toolchain assumptions, reducing copy/paste drift for future repos.

## Pitfalls encountered (and how to avoid them)
1. **Path drift between scripts and workflows**
   Scripts were not always using the same recipe location as workflows. Fix by setting one canonical recipe path and threading it through every entry point.
2. **Package installation assertions can silently rot**
   One workflow checked the wrong install directory shape for this package. Keep install assertions based on actual package layout (`lib/mojo/toml` here), not package name guesswork.
3. **Docs can lag after operational refactors**
   Validation docs and quick-start snippets often become stale first. Treat docs updates as required in the same PR as tooling changes.

## Repeatable checklist for other repositories
Use this for:
- `mojo-asciichart`
- `mojo-benchsuite`
- `mojo-data-star`
- `mojo-dotenv`
- `mojo-fireplace`
- `mojo-ini`
- `mojo-yaml`

1. **Create a migration branch**
   - `git checkout -b feature/mojo-1.0b1-migration`
2. **Pick one canonical recipe path**
   - Prefer `packaging/recipe.yaml` (or explicitly decide otherwise), then update all scripts/workflows/hooks/docs to match.
3. **Update Mojo import paths in `.mojo` files**
   - Migrate `collections`/`pathlib` imports to `std.collections`/`std.pathlib` as applicable.
4. **Run baseline validation**
   - `pixi run mojo-version`
   - `pixi run test-all`
   - `pixi run examples-all` (if present)
   - `pixi run validate-recipe`
   - `pixi run pre-submit -- --skip-modular-community` (or project equivalent)
5. **Fix failures by cluster**
   - Tooling path issues first, then import/syntax issues, then behavioural regressions.
6. **Update docs in same change set**
   - Any file containing migration-sensitive commands should be updated before merge.
7. **Capture repo-specific deltas**
   - Record exceptions (for example package install layout differences) so the next repo migration is faster.

## Current status (post-tranche update)
- Migration-to-beta validation for `mojo-toml` is complete and green.
- Version progression metadata has been aligned to `0.9.1`.
- `scripts/pre_submit_checklist.py` now supports both `context.version` and `package.version` recipe layouts.
- Operational docs were synchronised in both `docs/*.md` and `docs/planning/*.md`, while preserving intentionally historical release artefacts.

## Next tranche for mojo-toml
The next tranche should focus on optional warning-reduction and syntax modernisation polish (`fn`→`def` where required by target compiler behaviour), then re-run the full validation flow and fold findings back into this playbook.

## Next execution focus across sibling repos
The migration queue starts with repos that are closest to the completed `mojo-toml` pattern (`mojo-ini`, `mojo-yaml`, `mojo-dotenv`, `mojo-asciichart`) before moving to higher-variance repos (`mojo-benchsuite`, `mojo-data-star`, `mojo-fireplace`).
