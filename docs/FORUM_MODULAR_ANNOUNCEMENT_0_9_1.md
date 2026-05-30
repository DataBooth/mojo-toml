# Mojo 1.0 beta migration complete for 5 DataBooth libraries (all prior versions now deprecated)

Hi all — quick release update from my small `mojo-*` ecosystem.

I’ve now completed the Mojo 1.0 beta migration for these five libraries, all aligned on **`0.9.1`**:

- `mojo-toml`
- `mojo-ini`
- `mojo-yaml`
- `mojo-dotenv`
- `mojo-asciichart`

## What this means

- **`0.9.1` is now the supported baseline** for these five libraries.
- **All earlier versions are now deprecated** for these libraries.
- If you’re consuming them, please pin explicitly to `==0.9.1` for now.

## Why this release matters

The main goal was consistency and lower-friction maintenance across multiple repositories:

- one migration line,
- one compatible beta baseline,
- one clearer support target.

I’m hopeful this makes the final step from Mojo 1.0 beta to Mojo v1.0 smaller (or at least smaller than previous jumps).


Thanks to the Modular team and community — this ecosystem is still small, but I’m continuing to invest in it and keep it aligned with current Mojo releases.
