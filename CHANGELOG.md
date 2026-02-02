# Changelog

All notable changes to mojo-toml will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [Unreleased]

### Changed
- Bumped MAX / Mojo toolchain dependency to `max ">=26.1.0,<27"` and updated recipes to pin `mojo_version = "=0.26.1"`.
- Updated lexer, parser, writer, and tests to use `codepoint_slices()` and explicit `List[String]` buffers instead of direct `String` indexing or iteration, matching Mojo 0.26.1 string and `__getitem__` semantics.
- Adopted a "no warnings" policy for the core library and tests so future migrations surface only new issues.

### Planned for v0.6.0 - Remaining TOML 1.1
- Multiline inline tables with trailing commas
- Optional seconds in datetime/time values

### Planned for v0.7.0 - Performance
- Memory profiling and allocation analysis
- SIMD optimisations for string scanning (if needed)
- Large file handling optimisations (if needed)

## [0.5.0] - 2026-01-11

### Overview

**TOML 1.0 Complete!** 🎉 mojo-toml now implements the full TOML 1.0 specification with array-of-tables support and alternative number bases. This release brings the library to full TOML 1.0 compliance (with datetime values returned as ISO 8601 strings due to Mojo standard library development).

### Added ✅

**Alternative Number Bases:**
- Hexadecimal integers: `0xDEAD`, `0xdeadbeef`, `0xdead_beef`
- Octal integers: `0o755`, `0o01234567`  
- Binary integers: `0b11010110`, `0b1101_0110`
- Full support for underscores in alternative bases
- 14 comprehensive tests in `tests/test_number_bases.mojo`

**Array of Tables (`[[section]]`):**
- Complete implementation of TOML 1.0 array-of-tables syntax
- Simple arrays: `[[products]]` creates array of product tables
- Nested arrays: `[[fruit.variety]]` creates arrays within parent arrays
- Mixed tables and arrays in same document
- Dotted keys, inline tables, and arrays within array-of-tables elements
- Full conflict detection (array/table redefinition errors)
- 12 comprehensive tests in `tests/test_array_of_tables.mojo`

**Parser Enhancements:**
- Added `is_array_of_tables` state tracking to Parser struct
- Created `parse_array_of_tables_header()` for `[[...]]` syntax
- Implemented `ensure_array_of_tables_path()` for array creation/appending
- Implemented `set_in_array_of_tables_path()` for setting values in array elements
- Special handling for nested arrays where parent is an array
- Recursive approach handles arbitrary nesting depth

**TOML 1.1 Partial Support:**
- `\xHH` escape sequences for codepoints 0-255 (e.g., `\x00`, `\x61`)
- `\e` escape for escape character (U+001B)
- 5 comprehensive tests in `tests/test_toml11_escapes.mojo`
- Writer support for outputting `\e` and `\xHH` for control characters

**Benchmark System:**
- Created `benchmarks/machine_info.py` - system information extraction
- Created `benchmarks/report_utils.py` - markdown report generation
- Updated `benchmarks/compare_python.py` - Python baseline benchmarks
- Created `benchmarks/run_mojo_benchmark.py` - Mojo benchmark wrapper
- Both benchmarks generate markdown reports in `benchmarks/reports/`
- Reports include full system specs (OS, CPU, GPU, RAM, versions)
- `pixi run benchmark-mojo` - mojo-toml performance
- `pixi run benchmark-python` - Python tomllib/tomli_w baseline

**Testing:**
- **168 total tests** (up from 137)
- Parser tests: 127 (up from 96)
- Writer tests: 41 (unchanged)
- Removed 1 obsolete test (`test_array_of_tables_not_supported`)
- Auto-discovery test runner: `scripts/run_tests.py`

**Documentation:**
- Updated README with TOML 1.0 compliance statement
- Added TOML 1.1 roadmap section
- Documented datetime handling (ISO 8601 strings due to Mojo limitations)
- Added mojo-toml to official TOML implementations wiki

### Changed

**Lexer (`src/toml/lexer.mojo`):**
- Enhanced `read_number()` to detect `0x`, `0o`, `0b` prefixes
- Added digit validators: `is_hex_digit()`, `is_octal_digit()`, `is_binary_digit()`
- Proper tokenisation of alternative number base formats

**Parser (`src/toml/parser.mojo`):**
- Added integer parsing helpers: `parse_hex()`, `parse_octal()`, `parse_binary()`
- Modified `parse_integer()` to dispatch based on prefix detection
- Added array-of-tables detection in main parse loop
- Enhanced table/array conflict validation

**Test Organization:**
```
Parser Tests (127 total):
1. test_lexer.mojo (25 tests)
2. test_parser.mojo (10 tests)
3. test_real_world.mojo (4 tests)
4. test_fixtures.mojo (5 tests)
5. test_arrays.mojo (14 tests)
6. test_inline.mojo (13 tests)
7. test_tables.mojo (8 tests)
8. test_dotted_keys.mojo (7 tests)
9. test_validation.mojo (6 tests)  # Reduced by 1
10. test_parser_reset.mojo (3 tests)
11. test_number_bases.mojo (14 tests)  # NEW
12. test_array_of_tables.mojo (12 tests)  # NEW
13. test_toml11_escapes.mojo (5 tests)  # NEW

Writer Tests (41 total):
14. test_writer_basic.mojo (20 tests)
15. test_writer_tables.mojo (11 tests)
16. test_writer_roundtrip.mojo (10 tests)
```

**Documentation:**
- Reorganised `docs/` directory structure
- Moved planning/historical docs to `docs/planning/`
- Updated `PERFORMANCE.md` to focus on mojo vs Python comparison
- Added benchmark documentation to README.md
- Simplified Documentation section in README

**Project Structure:**
```
mojo-toml/
├── src/toml/           # Source code
│   ├── __init__.mojo   # Public API
│   ├── lexer.mojo      # Tokenisation + alt number bases + TOML 1.1 escapes
│   ├── parser.mojo     # Parsing + array-of-tables
│   └── writer.mojo     # TOML serialisation + escape sequences
├── tests/              # Test suite (168 tests)
├── benchmarks/         # Performance benchmarking system
├── docs/               # Documentation
│   ├── PERFORMANCE.md  # Active performance docs
│   └── planning/       # Planning and historical docs
```

### Technical Details

**Alternative Number Bases Implementation:**

Lexer detects prefixes and tokenizes digits:
```mojo
# In read_number():
if self.peek() == 'x': # Hexadecimal
    self.advance()  # Skip 'x'
    # Tokenize hex digits with underscores
elif self.peek() == 'o': # Octal
    # Tokenize octal digits
elif self.peek() == 'b': # Binary
    # Tokenize binary digits
```

Parser converts strings to integers:
```mojo
fn parse_hex(value: String) -> Int:
    # Strip underscores, convert base-16 to Int
    
fn parse_octal(value: String) -> Int:
    # Strip underscores, convert base-8 to Int
    
fn parse_binary(value: String) -> Int:
    # Strip underscores, convert base-2 to Int
```

**Array-of-Tables Implementation:**

Detection:
```mojo
if token.kind == TokenKind.LEFT_BRACKET():
    if peek().kind == TokenKind.LEFT_BRACKET():
        # Array of tables [[...]]
        self.is_array_of_tables = True
        self.current_table_path = self.parse_array_of_tables_header()
```

Array creation:
```mojo
fn ensure_array_of_tables_path(result, path):
    # For [[products]]: create/append to products array
    # For [[fruit.variety]]: handle nested arrays
    # Special handling when parent is array vs table
```

Value setting:
```mojo
fn set_in_array_of_tables_path(result, path, key, value):
    # Set key in last element of array at path
    # Handle nested arrays: [[fruit.variety]]
```

**Nested Array Example:**
```toml
[[fruit]]
name = "apple"

  [[fruit.variety]]
  name = "red delicious"

[[fruit]]
name = "banana"
```

Results in:
```json
{
  "fruit": [
    {
      "name": "apple",
      "variety": [
        {"name": "red delicious"}
      ]
    },
    {"name": "banana"}
  ]
}
```

### TOML 1.0 Compliance

mojo-toml now implements the complete TOML 1.0 specification:

✅ Basic types, strings, numbers, arrays, tables  
✅ Alternative number bases (hex/octal/binary)  
✅ Array of tables `[[section]]`  
✅ Nested structures, dotted keys  
✅ Duplicate detection, error messages  
✅ TOML writer with round-trip fidelity  

**Datetime values:** Parsed and validated per TOML 1.0, returned as ISO 8601 strings. Native Mojo datetime objects not yet used due to standard library development. This does not affect parsing correctness or round-trip fidelity.

### Migration Guide

No breaking API changes. All enhancements are backward compatible.

**Array-of-tables access:**
```mojo
from toml import parse

var config = parse(toml_content)
var products = config["products"].as_array()  # Get array
var first = products[0].as_table()  # Get first element
var name = first["name"].as_string()  # Access fields
```

**Alternative number bases:**
```mojo
# Automatically parsed - no API changes
var hex_val = config["value"].as_int()  # 0xDEAD → 57005
```

### Acknowledgements

Co-Authored-By: Warp <agent@warp.dev>

## [0.4.0] - 2026-01-11

### Overview

**TOML Writer Release** - mojo-toml now supports both reading and writing TOML files! This release adds complete serialisation capabilities with 41 comprehensive tests and full round-trip fidelity. 🎉

### Added ✅

**TOML Writer (`src/toml/writer.mojo`):**
- `to_toml()` function - serialises `Dict[String, TomlValue]` to TOML string
- Complete type support: strings, integers, floats, booleans, arrays, tables
- String escaping: `\`, `"`, `\n`, `\t`, `\r`
- Array formatting with proper nesting and mixed type support
- Inline table formatting: `{ key = "value" }`
- Table header formatting: `[section]` and `[section.subsection]`
- Recursive nested table serialisation
- Smart inline table heuristic (0-1 keys use inline format)

**Testing:**
- Created `tests/test_writer_basic.mojo` (20 tests) - primitive types and arrays
- Created `tests/test_writer_tables.mojo` (11 tests) - table structures
- Created `tests/test_writer_roundtrip.mojo` (10 tests) - round-trip verification
- **Critical test**: pixi.toml successfully round-trips (parse → write → parse preserves semantic equality)
- Total: **137 tests** (96 parser + 41 writer)

**Examples:**
- Created `examples/roundtrip.mojo` - comprehensive parse/modify/write workflow
- Shows practical round-trip usage patterns
- Demonstrates semantic equality verification

**Documentation:**
- Added writer documentation to README.md
- Created `docs/TOML_WRITER_DESIGN.md` - implementation design and architecture
- Updated quickstart with both reading and writing examples

**Build Tasks:**
- Added `pixi run test-writer-basic` task
- Added `pixi run test-writer-tables` task
- Added `pixi run test-writer-roundtrip` task
- Added `pixi run example-roundtrip` task

### Changed

**Public API:**
- Exported `to_toml()` from `src/toml/__init__.mojo`
- No breaking changes to existing parser API

**Project Structure:**
```
src/toml/
  __init__.mojo   # Public API: parse(), to_toml()
  lexer.mojo      # Tokenisation (unchanged)
  parser.mojo     # TOML parsing (unchanged)
  writer.mojo     # TOML serialisation [NEW]
```

### Technical Details

**Writer Architecture:**
```mojo
struct Writer:
    var buffer: String
    
    fn escape_string(self, s: String) -> String
    fn format_string/integer/float/boolean(...)
    fn format_array/inline_table(...)
    fn should_use_inline(self, table: Dict[String, TomlValue]) -> Bool
    fn write_key_value(...)
    fn write_table_header(path: List[String])
    fn write_table(path: List[String], table: Dict[String, TomlValue])
    fn to_string() -> String

fn to_toml(config: Dict[String, TomlValue]) raises -> String
```

**Inline Table Heuristic:**
- Tables with 0-1 keys and simple values: `{ key = "value" }` or `{ }`
- Larger tables: `[section]` format for readability
- Root-level sections always use `[section]` headers
- Nested tables use section headers `[a.b.c]`

**Round-Trip Fidelity:**
```mojo
# Semantic equality preserved (values match)
# Formatting/ordering may differ (whitespace, key order)
var original = parse(toml_content)
var written = to_toml(original)
var reparsed = parse(written)
assert compare_toml_values(original, reparsed)  # ✅ Passes
```

**String Escaping:**
- Backslash: `\\`
- Double quote: `\"`
- Newline: `\n`
- Tab: `\t`
- Carriage return: `\r`

### Usage Examples

**Write TOML:**
```mojo
from toml import to_toml, TomlValue

var config = Dict[String, TomlValue]()
var app = Dict[String, TomlValue]()
app["name"] = TomlValue("MyApp")
app["version"] = TomlValue("1.0.0")
config["app"] = TomlValue(app)

var toml_str = to_toml(config)
with open("config.toml", "w") as f:
    f.write(toml_str)
```

**Round-Trip:**
```mojo
from toml import parse, to_toml

var original = parse(read_file("config.toml"))
var modified = original  # Make changes...
var written = to_toml(modified)

with open("config_updated.toml", "w") as f:
    f.write(written)
```

### Known Behaviour

- Empty inline tables format as `{ }` (no extra spaces)
- Root-level sections always use `[section]` headers (never inline)
- Key ordering may differ after round-trip (Dict iteration order)
- Whitespace/formatting may differ (semantic equality preserved)
- Comments are not preserved (parser doesn't track them)

### Migration Guide

No breaking changes. New functionality is purely additive.

**New imports:**
```mojo
from toml import to_toml  # New writer function
from toml import parse    # Existing parser (unchanged)
```

### Acknowledgements

Co-Authored-By: Warp <agent@warp.dev>

## [0.3.0] - 2026-01-07

### Planned for v0.6.0 - Performance
- SIMD optimisations
- Performance benchmarks vs Python tomli

## [0.3.0] - 2026-01-07

### Overview

**Quality and performance release** with critical bug fixes, comprehensive testing improvements, performance documentation, and enhanced examples. All 96 tests passing! 🎉

### Added ✅

**Critical Fixes:**
- Proper dotted key support (`a.b.c = "value"` now creates nested structures)
- Duplicate key detection (raises errors on duplicate keys)
- Error messages with line and column context
- Named constants for TomlValue types (replaced magic numbers with `TomlValueType` struct)

**Parser Improvements:**
- `Parser.reset()` method for parser instance reusability
- `copy_path()` helper method to eliminate code duplication
- Enhanced comments explaining Mojo's ownership model and copying behaviour

**Performance & Benchmarking:**
- Comprehensive benchmark suite (`benchmarks/benchmark_parser.mojo`)
- Performance documentation (`docs/PERFORMANCE.md`)
- Measured parsing performance: 26μs for simple documents, 2ms for real pixi.toml
- Table access overhead documented as negligible (10μs)

**Testing:**
- Reorganized tests into 10 logical groupings (was 7 files)
- Renamed `test_basic.mojo` → `test_lexer.mojo` for clarity
- Created `test_validation.mojo` for error detection tests
- Created `test_dotted_keys.mojo` for dotted key functionality
- Created `test_parser_reset.mojo` for Parser API tests
- Added `TEST_ORGANIZATION.md` documenting test structure
- Total: **96 tests** (up from 79)

**Examples:**
- Enhanced `parse_pixi.mojo` with comprehensive configuration reporting
- Shows workspace, dependencies, tasks, and activation analysis
- Demonstrates advanced API usage patterns

**Documentation:**
- `PERFORMANCE.md` - Performance characteristics and copying behaviour
- `PERFORMANCE_IMPROVEMENTS_SUMMARY.md` - Branch work summary
- `TEST_ORGANIZATION.md` - Test structure and guidelines

### Changed

**Test Organization:**
1. test_lexer.mojo (25) - Lexer/tokenization (renamed from test_basic.mojo)
2. test_parser.mojo (10) - Parser core
3. test_real_world.mojo (4) - Real files
4. test_fixtures.mojo (5) - Complex examples
5. test_arrays.mojo (14) - Array parsing
6. test_inline.mojo (13) - Inline tables
7. test_tables.mojo (8) - Table headers
8. test_dotted_keys.mojo (7) - Dotted keys [NEW]
9. test_validation.mojo (7) - Error detection [NEW]
10. test_parser_reset.mojo (3) - Parser API [NEW]

**Parser Internals:**
- Magic numbers (0-5) replaced with `TomlValueType.STRING`, `.INTEGER`, etc.
- Using `comptime` constants for type discrimination
- Better error formatting throughout parser

### Technical Details

**Dotted Key Implementation:**
```mojo
# Now properly creates nested structure:
a.b.c = "value"  
# Results in: {a: {b: {c: "value"}}}
```

**Duplicate Key Detection:**
```mojo
key = "value1"
key = "value2"  # Error: "Duplicate key: key"
```

**Error Context:**
```
Error: Unexpected token at line 5, column 12
```

**Performance Benchmarks:**
- Simple parse: 37,000 parses/sec (26 μs)
- Nested tables: 4,370 parses/sec (228 μs)  
- Large documents: 290 parses/sec (3 ms)
- Real pixi.toml: 446 parses/sec (2 ms)
- Table access: 91,000 accesses/sec (10 μs) - negligible overhead

**Copying Behaviour:**
- Documented why copying is necessary in Mojo's ownership model
- String copies required to prevent partial destruction errors
- Dict/List copies required due to lack of borrowed method returns
- Performance impact measured and documented as acceptable

### Migration Guide

No breaking API changes. All enhancements are backward compatible.

### Acknowledgements

Co-Authored-By: Warp <agent@warp.dev>

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
