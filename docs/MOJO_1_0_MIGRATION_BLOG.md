# Mojo 1.0 beta migration wave: what changed, what worked, and what’s next
## Exec summary
Over this migration wave, I moved the in-scope DataBooth `mojo-*` libraries onto one consistent Mojo 1.0 beta baseline.

The goal was practical: reduce release friction, keep each package usable, and stop the “works in repo A, breaks in repo B” cycle.

The result is a cleaner operational path, better cross-repo consistency, and one shared `0.9.1` beta line with matching tags.

This post keeps the main story concise. Full technical notes are in the appendices.

## Why this migration now
The ecosystem has been moving quickly, and the repos had drifted in small but painful ways: packaging paths, validation assumptions, and compatibility handling.

None of those issues was huge on its own. Together, they created avoidable drag in day-to-day delivery.

So the migration focused on three things:
- one release approach across repos,
- one repeatable validation posture,
- and one version line for this beta phase.

## What was delivered
### 1) Operational consistency
For package-oriented repos, recipe handling and validation flow were aligned so local scripts, CI, and docs all reference the same source of truth.

### 2) Compatibility uplift
The key Mojo 1.0 beta breakpoints were addressed, including stricter API surfaces and checked-raises related test stabilisation.

### 3) Release alignment
All migrated repos now sit on a shared `0.9.1` beta line with corresponding tags, so consumers can target a coherent set of builds.

## Alignment with agentic engineering practice
This migration broadly followed the pattern in Modular’s write-up on building Mojo projects with AI agents:
- human-led architecture and product judgement,
- agent-led execution for repetitive, cross-repo, and boilerplate-heavy work.

Where I deliberately diverged: distribution policy. Because packaging is still evolving, the practical choice for now is controlled `0.9.1` beta releases with explicit consumer pinning.

Reference:
- https://www.modular.com/blog/how-i-built-a-pure-mojo-app-and-10-libraries-with-ai-agents

## Distribution stance for this beta phase
For these migrated DataBooth libraries, the recommendation is to consume the `0.9.1` beta line and avoid fallback to older 26.x-era community artefacts.

In practice:
- prefer DataBooth-hosted packages for these libraries,
- pin versions explicitly (`==0.9.1` is the safest default),
- use modular-community for other dependencies only where needed.

## Current status
This closes the current in-scope migration wave across:
- `mojo-toml`
- `mojo-ini`
- `mojo-yaml`
- `mojo-dotenv`
- `mojo-asciichart`
- `mojo-benchsuite`
- `mojo-data-star`
- `mojo-fireplace`

## What happens next
Near term, the plan stays simple and low-risk:
- keep the `0.9.1` beta line clean,
- keep release mechanics repeatable,
- revisit packaging strategy once the ecosystem settles further.

## Appendix A: Repo-level technical notes
### `mojo-ini`, `mojo-yaml`, `mojo-dotenv`, `mojo-asciichart`
- Consolidated recipe-path handling and pre-submit flow.
- Synced migration-sensitive docs with the operational command path.
- Retained passing validation with only non-blocking tool warnings.

### `mojo-benchsuite`
- Updated compatibility in benchmark plumbing.
- Removed brittle subprocess-based version probing.
- Confirmed benchmark task execution after migration.

### `mojo-data-star`
- Reworked the most brittle 1.0 beta interop surface.
- Simplified data-shape handling to reduce API churn exposure.
- Brought Mojo/Python test paths back into a stable green state.

### `mojo-fireplace`
- Stabilised Mojo test flow and environment assumptions.
- Updated test patterns for checked raises and current stdlib usage.
- Fixed practical runtime and test-path issues that blocked reliable local validation.

## Appendix B: Practical migration sequence used
1. Create or switch to `feature/mojo-1.0b1-migration`.
2. Resolve packaging and tooling path consistency first.
3. Run repo-native tests and validation.
4. Fix compiler and runtime issues in clusters.
5. Update docs in the same change set.
6. Re-run full validation before push.

## Appendix C: Consumer install policy example
For projects consuming the DataBooth beta-line releases:

```toml
[project]
channels = [
  "conda-forge",
  "https://conda.modular.com/max",
  "<DATABOOTH_CHANNEL_URL>"
]

[dependencies]
mojo-toml = "==0.9.1"
mojo-ini = "==0.9.1"
mojo-yaml = "==0.9.1"
mojo-dotenv = "==0.9.1"
mojo-asciichart = "==0.9.1"
```

If modular-community is present for other packages, explicit pins prevent accidental resolution to older incompatible builds for these libraries.
