+++
title = "Mojo 1.0 migration wave: what changed, what worked, and what’s next"
date = "2026-05-30"
draft = false
[taxonomies]
tags = [
  "Mojo 🔥",
  "Mojo 1.0",
  "Library Migration",
  "Release Engineering",
  "Open Source",
  "Packaging",
  "Testing",
  "Refactoring"
]
[extra]
comment = true
+++
# Mojo 1.0 migration wave: what changed, what worked, and what’s next
## Exec summary
Over this migration wave, I moved my `mojo-*` libraries onto one consistent Mojo 1.0 baseline.

The goal was practical: reduce release friction, keep each package usable, and stop the “works in repo A, breaks in repo B” cycle.

The result is a cleaner operational path, better cross-repo consistency, and a clear public release set aligned to Mojo 1.0.

This post keeps the main story concise. Full technical notes are in the appendices.

## Why this migration now
The ecosystem has been moving quickly, and the repos had drifted in small but painful ways: packaging paths, validation assumptions, and compatibility handling.

None of those issues was huge on its own. Together, they created avoidable drag in day-to-day delivery.

So the migration focused on three things:
- one release approach across repos,
- one repeatable validation posture,
- and one version line for this 1.0 phase.

## What was delivered
### 1) Operational consistency
For package-oriented repos, recipe handling and validation flow were aligned so local scripts, CI, and docs all reference the same source of truth.
Code-quality automation was also standardised on `prek` as the git-hook runner, while retaining `.pre-commit-config.yaml` compatibility.

### 2) Compatibility uplift
The key Mojo 1.0 breakpoints were addressed, including stricter API surfaces and checked-raises related test stabilisation.

### 3) Release alignment
All migrated repos now sit on a shared `0.9.1` line with corresponding tags, so consumers can target a coherent set of builds.

## Alignment with agentic engineering practice
This migration broadly followed the pattern in Modular’s write-up on building Mojo projects with AI agents:
- human-led architecture and product judgement,
- agent-led execution for repetitive, cross-repo, and boilerplate-heavy work.

Where I deliberately diverged: distribution policy. Because packaging is still evolving, the practical choice for now is controlled `0.9.1` releases with explicit consumer pinning.

Reference:
- https://www.modular.com/blog/how-i-built-a-pure-mojo-app-and-10-libraries-with-ai-agents

## Distribution stance for this phase
For these migrated DataBooth libraries, the recommendation is to consume the current Mojo 1.0-aligned line and avoid fallback to older 26.x-era community artefacts.

In practice:
- prefer DataBooth-hosted packages for these libraries,
- pin versions explicitly (`==0.9.1` is the safest default),
- use modular-community for other dependencies only where needed.

## Public release scope for this wave
This public release now focuses on five libraries:
- `mojo-toml`
- `mojo-ini`
- `mojo-yaml`
- `mojo-dotenv`
- `mojo-asciichart`

## Current status
This closes the current migration execution wave across:
- `mojo-toml`
- `mojo-ini`
- `mojo-yaml`
- `mojo-dotenv`
- `mojo-asciichart`

## What happens next
Near term, the plan stays simple and low-risk:
- publish and support the five-library `0.9.1` release cleanly,
- keep release mechanics repeatable,
- revisit packaging strategy once the ecosystem settles further.

## Appendix A: Repo-level technical notes
### `mojo-ini`, `mojo-yaml`, `mojo-dotenv`, `mojo-asciichart`
- Consolidated recipe-path handling and pre-submit flow.
- Synced migration-sensitive docs with the operational command path.
- Migrated local hook commands from `pre-commit` to `prek`.
- Retained passing validation with only non-blocking tool warnings.


## Appendix B: Practical migration sequence used
1. Create or switch to `feature/mojo-1.0b1-migration`.
2. Resolve packaging and tooling path consistency first.
3. Run repo-native tests and validation.
4. Fix compiler and runtime issues in clusters.
5. Update docs in the same change set.
6. Re-run full validation before push.
## Appendix C: `mojo-toml` pilot gotchas under Mojo 1.0
### Recursive value model breakage
The most significant compiler blocker in the pilot was recursive storage in `TomlValue`.

Direct fields like `List[TomlValue]` and `Dict[String, TomlValue]` now fail with a Deinitable constraint error under Mojo 1.0.

The working pattern was to store recursive values as boxed entries and implement explicit deep-copy + cleanup behaviour in the value type.

### Secondary stdlib/source updates
Two smaller migration fixes were also required:
- update `math` imports to `std.math`,
- replace `len(String)` usage with explicit string-length APIs (`byte_length()` in numeric-prefix checks).

### Validation evidence
After these fixes, `pixi run test-all` passed all suites in `mojo-toml` on Mojo 1.0.
## Appendix D: Wave A gotchas and fix patterns (`mojo-asciichart`, `mojo-dotenv`, `mojo-ini`, `mojo-yaml`)
### Cross-repo mechanical changes that were consistently required
- Replace legacy `fn` declarations with `def` across sources, tests, examples, and packaging smoke tests.
- Move imports to current stdlib paths where required (`std.math`, `std.python`, `std.pathlib`, `std.os`).
- Replace ambiguous string operations (`len(String)` and direct string slicing) with explicit Mojo 1.0 APIs (`byte_length()`, `s[byte=...]`).
- Add `raises` annotations through test call chains where parser and loader APIs can throw.

### `mojo-dotenv` specific notes
- `pathlib` and `os` imports needed migration to `std.pathlib` and `std.os`.
- Parser internals required UTF-8-safe string handling updates in export-prefix stripping and empty-string checks.
- Validation result: `pixi run test-all` passed all 11 suites; `pixi run build-package` succeeded (warnings only).

### `mojo-ini` specific notes
- Lexer had hidden `len(self.input)` checks that needed conversion to character-buffer length checks (`len(self.chars)`).
- One string-length assertion in error tests needed conversion to `byte_length()` to satisfy Mojo 1.0 string semantics.
- Validation result: `pixi run test-all` passed all 5 suites; `pixi run build-package` succeeded (warnings only).

### `mojo-yaml` specific notes
- The initial `YamlValue` recursive model (`List[YamlValue]`/`Dict[String, YamlValue]`) failed under Mojo 1.0 with Deinitable constraints, mirroring the earlier TOML pilot issue.
- The fix pattern was the same as `mojo-toml`: boxed recursive storage with explicit deep-copy and deinit ownership handling.
- A follow-up test adaptation was needed where debug tests directly traversed sequence internals; accessor-based reads avoided pointer-type misuse.
- Validation result: `pixi run test-all` passed all 15 suites; `pixi run build-package` succeeded (warnings only).
## Appendix E: Wave B gotchas and fix patterns (`mojo-benchsuite`)
- `mojo-benchsuite` started from a nightly-channel posture; migration switched it to stable Mojo 1.0 channels and explicit runtime pinning.
- Benchmark callback wiring needed a Mojo 1.0 API update: thin benchmark functions now run via explicit callable parameters (`auto_benchmark(name, benchmark_func, min_runtime_secs)`).
- Legacy helpers like `String.ljust` and implicit `len(String)` usage required replacement (`byte_length()` plus local padding helper).
- Import paths also needed modernisation in benchmark internals (`std.time`, `std.sys`, `std.python`).
- Validation result:
  - `pixi run test` (adaptive smoke benchmark) passed,
  - `pixi run bench-all` completed all six benchmark suites successfully.

## Appendix F: Consumer install policy examples
### Option 1: Packaged installs via a DataBooth channel (recommended)
For packaged releases, use one package channel URL plus explicit pins:

```toml
[project]
channels = [
  "conda-forge",
  "https://conda.modular.com/max",
  "<DATABOOTH_CONDA_CHANNEL_URL>"
]

[dependencies]
mojo-toml = "==0.9.1"
mojo-ini = "==0.9.1"
mojo-yaml = "==0.9.1"
mojo-dotenv = "==0.9.1"
mojo-asciichart = "==0.9.1"
```

Important: `<DATABOOTH_CONDA_CHANNEL_URL>` is the package index/channel endpoint, not individual GitHub repository URLs.

If modular-community is present for other packages, explicit pins prevent accidental resolution to older incompatible builds for these libraries.

### Option 2: Source consumption from GitHub repos (follow-up or experimental)
If you want to consume directly from source, add each library repo and include its `src` path when running Mojo:

```bash
git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml
git submodule add https://github.com/databooth/mojo-ini vendor/mojo-ini
git submodule add https://github.com/databooth/mojo-yaml vendor/mojo-yaml
git submodule add https://github.com/databooth/mojo-dotenv vendor/mojo-dotenv
git submodule add https://github.com/databooth/mojo-asciichart vendor/mojo-asciichart
```

```bash
mojo \
  -I vendor/mojo-toml/src \
  -I vendor/mojo-ini/src \
  -I vendor/mojo-yaml/src \
  -I vendor/mojo-dotenv/src \
  -I vendor/mojo-asciichart/src \
  your_app.mojo
```
