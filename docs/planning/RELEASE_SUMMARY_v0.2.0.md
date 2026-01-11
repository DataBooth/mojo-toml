# v0.2.0 Release Summary

## Ready to Release! 🚀

**Branch:** `feature/nested-tables`  
**Version:** v0.2.0  
**Date:** 2026-01-07  
**Tests:** All 79 passing ✅

## What's New in v0.2.0

### Major Feature: Nested Table Structures 🎉

Thanks to community feedback on Modular Discord, we discovered that Dict iteration works without the `[]` subscript operator. This enabled full nested table implementation!

**Before (never released):**
```mojo
var host = config["database.host"].as_string()  // Flat keys
```

**Now (v0.2.0):**
```mojo
var db = config["database"].as_table()
var host = db["host"].as_string()  // Proper nesting!
```

### Implementation Highlights

- Fixed `TomlValue.copy()` and `as_table()` to use proper Dict iteration
- Added `ensure_table_path()` for recursive table creation
- Added `set_in_table_path()` for setting values at any depth
- Supports arbitrary nesting depth: `[a.b.c.d.e]`
- All 79 tests passing with nested structures

### Files Changed

**Core:**
- `src/toml/parser.mojo` - Nested table implementation (~650 lines)

**Tests:**
- `tests/test_tables.mojo` - Updated for nested access (8 tests)
- `tests/dev/` - Preserved development tests documenting the discovery

**Documentation:**
- `README.md` - v0.2.0 features and roadmap
- `CHANGELOG.md` - Complete v0.2.0 entry with migration guide
- `docs/TABLE_HEADERS_BLOCKER.md` - Solution documented
- `.github/RELEASE_NOTES_v0.2.0.md` - GitHub release notes

**Examples:**
- `examples/parse_pixi.mojo` - Demonstrates nested tables

## TOML 1.0 Compliance Status

### ✅ Implemented (v0.2.0)
- Key-value pairs
- Comments
- Strings (basic, literal, multiline)
- Numbers (integers, floats, special values)
- Booleans
- Arrays (nested, mixed types)
- Inline tables (with nesting)
- **Table headers with proper nested structures** ⭐ NEW
- Dotted table headers: `[a.b.c]`
- Datetime strings (ISO 8601)

### 🚧 Planned for v0.3.0 - TOML 1.0 Compliance
1. **Array of tables** `[[array]]` - For repeated sections
2. **Duplicate key detection** - Reject invalid files
3. **Hex/Octal/Binary integers** - `0xDEAD`, `0o755`, `0b1101`
4. **Dotted keys** - `a.b.c = "value"` in regular key-value pairs
5. **Native datetime types** - Parse to datetime objects vs strings
6. **Enhanced error messages** - Better context and line numbers

### 📝 Future Versions
- **v0.4.0:** Writer/serialiser functionality
- **v0.5.0:** SIMD optimisations and performance benchmarks

## Release Steps

### 1. Commit and Push Branch

```bash
# Review changes
git status
git diff --stat

# Commit
git add -A
git commit -m "feat: Implement nested table structures for v0.2.0

Major breakthrough implementing proper nested TOML tables thanks to
Modular Discord community feedback about Dict iteration patterns.

Changes:
- Fixed TomlValue Dict iteration (use entry.key/value without [])
- Implemented recursive nested table building
- Updated all table tests for nested access
- All 79 tests passing

Features:
- Proper nested table structures: config[\"db\"].as_table()[\"host\"]
- Deep nesting support: [a.b.c.d.e]
- Parses real-world files (pixi.toml) successfully

Documentation:
- Updated README, CHANGELOG for v0.2.0
- Documented solution in TABLE_HEADERS_BLOCKER.md
- Added v0.3.0 roadmap (TOML 1.0 compliance features)

Skipped v0.1.0-alpha and jumped directly to v0.2.0 with nested tables.

Co-Authored-By: Warp <agent@warp.dev>"

# Push branch
git push origin feature/nested-tables
```

### 2. Create Pull Request

- Go to https://github.com/databooth/mojo-toml
- Create PR: `feature/nested-tables` → `main`
- Title: "v0.2.0: Nested Table Structures"
- Description: Link to release notes or paste summary
- Review in GitHub interface
- Merge when ready

### 3. Tag and Release

```bash
# After merging to main
git checkout main
git pull origin main

# Create tag
git tag -a v0.2.0 -m "v0.2.0 - Nested Table Structures

First release with proper nested TOML table support!

Major thanks to Modular Discord community for the Dict iteration tip.

See CHANGELOG.md for full details."

# Push tag
git push origin v0.2.0
```

### 4. Create GitHub Release

1. Go to https://github.com/databooth/mojo-toml/releases/new
2. Choose tag: `v0.2.0`
3. Release title: `v0.2.0 - Nested Tables 🎉`
4. Copy content from `.github/RELEASE_NOTES_v0.2.0.md`
5. **DO NOT check "Set as pre-release"** (this is production-ready)
6. Click "Publish release"

The `build-package.yml` workflow will automatically build and attach `toml.mojopkg`.

### 5. Verify Release

- [ ] Release appears at https://github.com/databooth/mojo-toml/releases
- [ ] Tag v0.2.0 visible in GitHub
- [ ] CI workflows passing (check Actions tab)
- [ ] .mojopkg attached to release (takes a few minutes)

## Post-Release (Optional)

### Share Success
- Post to Modular Discord #mojo channel thanking community
- Include link to release
- Mention the Dict iteration discovery

### Monitor
- Watch for issues
- Respond to feedback
- Track interest for modular-community submission timing

## Before modular-community Submission

**As you mentioned, wait for:**
1. Warp code review (check for issues/simplification opportunities)
2. More testing with real-world files
3. Manual code review
4. Consider implementing some v0.3.0 features first

**The parser is functional and well-tested, but these are good precautions before wider distribution.**

## Notes

- **No breaking changes** from any previous version (v0.1.0-alpha was never released)
- Tests cover: lexer (25), parser (10), real-world (4), fixtures (5), arrays (14), inline tables (13), tables (8)
- Successfully parses pixi.toml and other real configuration files
- Zero Python dependencies
- Documented workaround becomes permanent solution!

---

**Status:** Ready for GitHub release  
**Blocker:** None - all systems go! 🚀
