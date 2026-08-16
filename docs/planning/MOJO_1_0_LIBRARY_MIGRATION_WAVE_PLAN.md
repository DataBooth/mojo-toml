# Mojo 1.0 Library Migration Wave Plan
## Problem statement
Mojo has reached the 1.0 release phase, and the DataBooth `mojo-*` libraries need a coordinated migration from mixed pre-1.0 and beta-era assumptions to a stable, repeatable Mojo 1.0 baseline. The migration should also produce a progressive public narrative capturing gotchas, lessons, and release-engineering decisions.
## Current state
`mojo-toml` is the furthest along and already uses a workspace manifest plus a 1.0 beta pin (`pixi.toml:1`, `pixi.toml:68`) with an existing migration write-up (`docs/MOJO_1_0_MIGRATION_BLOG.md:2`, `docs/MOJO_1_0_MIGRATION_BLOG.md:4`).
Other target repos still show pre-1.0 posture in one or more places:
* `../mojo-asciichart/pixi.toml:1` and `../mojo-asciichart/pixi.toml:47`
* `../mojo-dotenv/pixi.toml:1` and `../mojo-dotenv/pixi.toml:58`
* `../mojo-ini/pixi.toml:1` and `../mojo-ini/pixi.toml:49`
* `../mojo-yaml/pixi.toml:1` and `../mojo-yaml/pixi.toml:46`
Packaging compiler pins remain at `=0.26.1` in several repos:
* `../mojo-asciichart/packaging/recipe.yaml:3`
* `../mojo-dotenv/packaging/recipe.yaml:3`
* `../mojo-ini/packaging/recipe.yaml:3`
* `../mojo-yaml/packaging/recipe.yaml:3`
`mojo-benchsuite` currently uses a nightly channel and has a placeholder test task (`../mojo-benchsuite/pixi.toml:3`, `../mojo-benchsuite/pixi.toml:40`), so its migration needs both compatibility and release-hardening work.
## Proposed changes
### 1) Establish canonical Mojo 1.0 policy in `mojo-toml` first
Use `mojo-toml` as the pilot repo to define canonical policy for:
* dependency pinning strategy for Mojo 1.0 (runtime + packaging/compiler constraints)
* channels and manifest schema conventions
* recipe pin and compatibility policy
* CI matrix and release validation expectations
Any unresolved ambiguity (pin granularity, channel order, lockfile policy) is decided once in `mojo-toml`, then reused in all sibling repos.
### 2) Create a shared migration playbook before editing sibling repos
After pilot validation in `mojo-toml`, codify one playbook for every repo:
* manifest normalization (`[project]`/`[workspace]`, channels, dependency policy)
* recipe/compiler pin migration and package smoke-test rules
* source/test syntax and stdlib compatibility updates required by 1.0
* CI/workflow parity requirements (tests, recipe validation, package build)
* post-migration verification commands and acceptance checks
This avoids six one-off migrations and keeps release behavior consistent.
### 2a) Pilot outcomes from `mojo-toml` (playbook v1)
The pilot uncovered one hard compatibility blocker and several mechanical updates that should now be applied proactively in sibling repos.
Core reusable pattern:
* **Recursive value model fix**: Mojo 1.0 rejects direct recursive container fields such as `List[Self]`/`Dict[String, Self]` with Deinitable errors. Use boxed recursive storage (`Pointer[..., MutUntrackedOrigin]`) plus explicit deep-copy and `__deinit__` cleanup for owned boxed values.
Mechanical language/std changes to apply early:
* replace legacy `fn` declarations with `def`
* move test imports from `testing` to `std.testing`
* prefer `std.<module>` import paths (for example `std.math`)
* replace `len(String)` usage with explicit length APIs (`byte_length()`, `len(codepoints())`, or `len(graphemes())` as appropriate)
Validation gate proven in pilot:
* `pixi lock`
* `pixi run mojo-version`
* `pixi run test-all`
* `pixi run build-package`
If these pass in each repo, the migration is functionally complete for that repo’s baseline.
### 3) Roll out to remaining repos in controlled waves
Apply the playbook in two rollout waves:
* Wave A: `../mojo-asciichart`, `../mojo-dotenv`, `../mojo-ini`, `../mojo-yaml`
* Wave B: `../mojo-benchsuite` (includes extra hardening because of current nightly/testing posture)
Each repo migration ends with local validation + CI alignment before moving on.
### 4) Keep release engineering in scope
Migration is complete per repo only when source compatibility and release mechanics both pass:
* tests/examples/benchmarks (repo-appropriate)
* recipe validation
* package build and smoke install checks
* docs alignment for install and release workflows
## Progressive blog capture strategy
Run a parallel documentation stream from day one:
* Keep `docs/MOJO_1_0_MIGRATION_BLOG.md` in `mojo-toml` as the canonical living narrative draft.
* Add structured per-repo migration notes (“what changed / what broke / fix pattern / validation evidence”).
* After each repo wave, fold validated lessons into the central draft with concrete gotchas and reusable patterns.
* Publish once all six repos are migrated and validated, with an appendix of practical interop/tooling pitfalls and mitigations.
## Risk management
Primary risks are hidden API/stdlib incompatibilities, packaging drift, and release workflow regressions.
Mitigation approach:
* pilot-first policy in `mojo-toml`
* strict reuse of one migration playbook
* verification gates at repo boundaries
* progressive documentation so repeated failures become explicit reusable fixes
## Success criteria
Success means all six repos are on a coherent Mojo 1.0 baseline with aligned manifests, recipes, and CI/release workflows, and a publication-ready migration article exists documenting practical gotchas and lessons from the full wave.
