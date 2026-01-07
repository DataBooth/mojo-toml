# Changelog

All notable changes to mojo-toml will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v0.3.0 - TOML 1.0 Compliance
- Array of tables: `[[array]]`
- Duplicate key detection
- Hex/Octal/Binary integers: `0xDEADBEEF`, `0o755`, `0b11010110`
- Dotted keys in key-value pairs: `a.b.c = "value"`
- Native datetime parsing (parse to datetime types vs strings)
- Enhanced error messages with context

### Planned for v0.4.0 - Writer
- Serialise `Dict` to TOML string
- Pretty printing options
- Round-trip fidelity

### Planned for v0.5.0 - Performance
- SIMD optimisations
- Performance benchmarks vs Python tomli

## [0.2.0] - 2026-01-07

### Overview

**Major breakthrough:** Nested table structures now fully implemented! 🎉

Following feedback from the Modular Discord community, we discovered that Mojo's Dict iterator works without the `[]` subscript operator (using `entry.key` and `entry.value` directly). This enabled proper nested table implementation, allowing us to skip v0.1.0-alpha and jump directly to v0.2.0.

### Added - Nested Tables ✅

**Parser Improvements:**
- Proper nested table structures using recursive Dict building
- Tables accessed via `.as_table()` method returning nested Dicts
- Dotted table headers `[a.b.c]` create properly nested structures
- Deep nesting supported (e.g., `[a.b.c.d.e]`)
- All 79 tests passing with nested structure access

**Implementation:**
- Fixed `TomlValue.copy()` to use proper Dict iteration (`entry.key`, `entry.value`)
- Fixed `TomlValue.as_table()` to return properly copied nested Dicts
- Added `ensure_table_path()` helper to create nested table paths
- Added `set_in_table_path()` helper to set values at nested paths
- Recursive approach handles arbitrary nesting depth

**Testing:**
- Updated all 8 table tests to expect nested access patterns
- All tests pass: `config["database"].as_table()["host"]`
- Test suite validates deep nesting, multiple tables, inline tables in tables

**Examples:**
- Updated `parse_pixi.mojo` to demonstrate nested table access
- Successfully parses pixi.toml with proper nested structure
- Shows idiomatic nested Dict navigation

**Documentation:**
- Updated README with nested table examples
- Removed all flat key storage references
- Added explanation of nested access patterns
- Created `tests/dev/README.md` documenting the breakthrough

### Changed

- **API Change**: Table access now requires `.as_table()` call
  - Old (flat): `config["database.host"].as_string()`
  - New (nested): `config["database"].as_table()["host"].as_string()`
- Parser now builds proper nested Dict structures instead of flat keys
- `parse()` method returns nested `Dict[String, TomlValue]`

### Technical Details

**Key Discovery:**
Mojo's `DictEntry` can be accessed without subscripting:
```mojo
# Works! ✅
for entry in dict.items():
    var k = entry.key
    var v = entry.value

# Don't need! ❌
for entry in dict.items():
    var k = entry[].key  # Was causing errors
```

**Implementation Pattern:**
- Copy Dicts during iteration to avoid ownership issues
- Return new Dicts from helper functions (pure functional style)
- Use temporary variables to avoid aliasing with `self`

### Removed

- Flat key storage implementation (replaced with nested structures)
- `KeyValuePair` struct (was workaround for Dict iteration)
- Flat key access patterns from tests and examples

### Migration Guide

If you were using an earlier development version with flat keys:

```mojo
# Before (flat keys - v0.1.0-alpha dev)
var host = config["database.host"].as_string()

# After (nested tables - v0.2.0)
var db = config["database"].as_table()
var host = db["host"].as_string()
```

### Acknowledgements

Thanks to the Modular Discord community for the feedback that `entry.key` and `entry.value` work without subscripting, enabling this implementation!

### Known Limitations

Still not implemented:
- Array of tables `[[array]]`
- Duplicate key detection  
- Native datetime parsing (returns ISO 8601 strings)

## [0.1.0-alpha] - 2026-01-07 (Skipped)

### Overview

First alpha release of mojo-toml — the first native TOML 1.0 parser for Mojo! 🔥

This release provides functional TOML parsing for most common use cases. Due to a current Mojo language limitation with Dict iterators, table headers use **flat key storage** as an interim solution. See `docs/TABLE_HEADERS_BLOCKER.md` for technical details.

### Added - Core Parser ✅

**Lexer (540 lines):**
- Complete tokenisation for all TOML 1.0 elements
- String tokens (basic, literal, multiline)
- Number tokens (integers, floats, special values: inf, nan)
- Boolean tokens
- Array and inline table tokens
- Table header tokens
- Comment handling
- Line/column tracking for error messages

**Parser (~620 lines):**
- Key-value pairs: `key = "value"`
- Comments: `# comment`
- Strings: basic `"string"`, literal `'string'`, multiline variants
- Numbers: integers, floats, underscores for readability, special values (inf, -inf, nan)
- Booleans: `true`, `false`
- Arrays: `[1, 2, 3]` with nesting, mixed types, trailing commas
- Inline tables: `{name = "value"}` with nesting and arrays inside
- Table headers: `[section]` using flat key storage
- Dotted table headers: `[a.b.c]`
- Datetime strings: ISO 8601 format (returned as strings)
- Clear error messages with line/column information

**Testing:**
- 79 tests passing across 7 test suites
- test_basic.mojo - 25 lexer tests
- test_parser.mojo - 10 parser tests  
- test_real_world.mojo - 4 real TOML file tests
- test_fixtures.mojo - 5 fixture tests
- test_arrays.mojo - 14 array tests
- test_inline.mojo - 13 inline table tests
- test_tables.mojo - 8 table header tests
- All tests validate against expected behaviour
- Successfully parses real-world files (pixi.toml)

**Examples:**
- `examples/simple.mojo` - Comprehensive demonstration
- `examples/parse_pixi.mojo` - Parses actual pixi.toml

**Documentation:**
- Complete README with usage examples
- API documentation (parse function)
- Installation instructions (git submodule, direct copy)
- Roadmap and feature status
- `docs/TABLE_HEADERS_BLOCKER.md` - Technical explanation of flat key limitation
- `docs/DISCORD_POST.md` - Community discussion draft

### ⚠️ Interim Approach - Flat Key Storage

Due to a Mojo language limitation with Dict iterator subscripting, table headers are stored as flat dotted keys:

```mojo
# TOML input:
# [database]
# host = "localhost"
# port = 5432

# Current access pattern (flat keys):
var host = config["database.host"].as_string()
var port = config["database.port"].as_int()

# Future access pattern (nested - not yet available):
var db = config["database"].as_table()
var host = db["host"].as_string()
```

This is a pragmatic workaround that enables the parser to be functional today while awaiting language improvements.

### Known Limitations

**Not Yet Implemented:**
- Array of tables: `[[array]]`
- Duplicate key detection
- Nested table structures (see flat key storage above)
- Native datetime parsing (returns ISO 8601 string instead)
- Writer/serialiser functionality
- Full TOML 1.0 spec compliance

**API Stability:**
- ⚠️ **Breaking changes expected in v0.2.0** when nested table support is added
- The flat key access pattern will change to nested dict access
- Migration will be straightforward but not automatic

### Compatibility

- **Tested with:** Mojo 2025/2026 (via pixi)
- **Platforms:** macOS (Apple Silicon), Linux (via CI)
- **Zero Python dependencies** for runtime usage

### Infrastructure

- pixi development environment
- Comprehensive test suite with `pixi run test-all`
- Individual test tasks for quick iteration
- Example runner tasks
- Build task for creating .mojopkg packages
- GitHub workflows for CI testing

---

## Release Checklist

Before tagging a release:

- [ ] Update version in README.md status line
- [ ] Update this CHANGELOG.md with release date
- [ ] Run full test suite: `pixi run test-all`
- [ ] Run examples: `pixi run example-simple` and `pixi run example-pixi`
- [ ] Build package: `pixi run build-package`
- [ ] Update PLAN.md if scope changed
- [ ] Create git tag: `git tag -a v0.1.0-alpha -m "Release v0.1.0-alpha"`
- [ ] Push tag: `git push origin v0.1.0-alpha`
- [ ] Create GitHub release with CHANGELOG excerpt
- [ ] (Optional) Upload .mojopkg to GitHub release with Mojo version note

## Version History

- **v0.1.0-alpha** (2026-01-07): First alpha release - Core parser functional with 79 tests passing

---

**Links:**
- [GitHub Repository](https://github.com/databooth/mojo-toml)
- [GitHub Releases](https://github.com/databooth/mojo-toml/releases)
- [Technical Plan](docs/PLAN.md)
- [TOML 1.0 Specification](https://toml.io/en/v1.0.0)
