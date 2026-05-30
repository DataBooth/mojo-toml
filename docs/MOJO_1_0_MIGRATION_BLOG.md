# mojo-* migration notes: what we learned moving to Mojo 1.0.0b1
This write-up captures the full multi-repo migration wave across the DataBooth `mojo-*` libraries. The goal was practical: get everything onto a stable Mojo 1.0 beta workflow without breaking day-to-day development speed.

## Why this wave mattered
We were carrying a mix of old and new assumptions across repositories:
- recipe validation paths diverged between local scripts, CI, and pre-commit,
- several packages still depended on legacy import/syntax patterns,
- test harnesses worked in one repo and failed in another for avoidable reasons,
- and docs were increasingly out of sync with real commands.

In short, this was operational debt, not just code debt.

## What we standardised across repositories
## 1) Packaging path consistency
For packaging-focused repos, we standardised on `packaging/recipe.yaml` and pushed that path through:
- `pixi.toml` tasks,
- build/validation scripts,
- pre-submit checklists,
- pre-commit hooks,
- workflow triggers,
- and docs.

Repos where this was applied in this tranche:
- `mojo-toml`
- `mojo-ini`
- `mojo-yaml`
- `mojo-dotenv`
- `mojo-asciichart`

## 2) Mojo 1.0 compatibility fixes
The recurring upgrade pattern was:
- move legacy imports to `std.*` where needed,
- remove or replace APIs removed in 1.0 beta,
- align tests with checked-raises semantics (`raises` where assertion helpers may raise),
- and tighten task definitions so local validation matches real usage.

## 3) Validation discipline
Every repo was migrated with repo-native validation, not assumptions. Typical command sets included:
- `pixi run test-all` (or equivalent),
- targeted benchmark/example smoke runs where tests are limited,
- `pixi run validate-recipe` for packaging repos,
- and Python syntax checks where checklist scripts changed.

## Repo-by-repo findings
## mojo-ini / mojo-yaml / mojo-dotenv / mojo-asciichart
These four were the cleanest high-leverage wins:
- recipe-path drift resolved end-to-end,
- pre-submit scripts aligned,
- docs updated in the same change set,
- validations passed with only non-blocking pixi/lock-format warnings.

The important lesson: fixing operational path drift early removes most migration friction.

## mojo-benchsuite
Primary issue was framework-level Mojo compatibility in benchmark plumbing:
- modernised collection imports,
- removed brittle Python subprocess pattern used for version probing,
- confirmed benchmark tasks (`run-example`, `bench-adaptive`, `bench-comprehensive`) still execute.

This repo highlighted that benchmark frameworks are often more API-sensitive than the benchmark kernels themselves.

## mojo-data-star
This was the sharpest 1.0 API delta in the wave:
- old tensor/layout + PythonObject conversion paths no longer compiled cleanly,
- migrated to a simpler `MandelbrotGrid` representation for native Mojo tests,
- updated checked-raises usage in Mojo tests,
- rebased pixi constraints to the MAX 26.x line.

Key takeaway: where interop APIs are still moving, simpler data models reduce upgrade risk substantially.

## mojo-fireplace
This repo needed a pragmatic test-flow stabilisation rather than full code modernisation:
- ensured Mojo CLI availability in pixi env via MAX channel/dependency,
- migrated Mojo test files to `std.testing` + checked-raises signatures,
- fixed AoC string parsing that relied on deprecated slicing behaviour,
- removed obsolete `Stringable` trait usage in Game of Life `gridv1`,
- fixed Python interop test collection by setting `PYTHONPATH` in task execution.

Outcome: the consolidated `pixi run test` path now passes on the migrated branch for the covered matrix.

## The patterns that repeatedly bit us
1. **Checked raises in tests**
   Assertion helpers can raise; test functions and `main()` often need `raises` now.
2. **String and conversion API drift**
   Legacy convenience idioms (for example old slicing/conversion shortcuts) are now stricter.
3. **Tooling path drift beats code drift**
   More breakage came from scripts/hooks/workflows disagreeing than from core algorithms.
4. **Interop wrappers age faster than core logic**
   The pure compute kernels were usually fine; wrapper layers were where most compile churn appeared.

## Practical migration playbook (kept short)
1. Branch: `feature/mojo-1.0b1-migration`
2. Fix packaging/tooling path consistency first.
3. Run tests, then fix compile/runtime issues in clusters.
4. Update docs in the same commit range.
5. Re-run full validation commands before push.

## Current status
Migration commits are pushed on `feature/mojo-1.0b1-migration` for:
- `mojo-ini`
- `mojo-yaml`
- `mojo-dotenv`
- `mojo-asciichart`
- `mojo-benchsuite`
- `mojo-data-star`
- `mojo-fireplace`

Alongside the earlier `mojo-toml` completion work, this closes the current in-scope migration wave.
