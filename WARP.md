# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

mojo-toml is a native TOML 1.0 parser and writer for Mojo with zero Python dependencies. The project uses pixi for dependency management and provides a clean, type-safe API for parsing and writing TOML configuration files.

**Status:** v0.4.0 - 137 tests passing (96 parser + 41 writer), production-ready with full round-trip support

## Essential Commands

### Testing
```bash
# Run all 137 tests across 13 test suites
pixi run test-all

# Run individual test suites (for faster iteration)
# Parser tests (96 total)
pixi run test-lexer          # 25 tokenisation tests
pixi run test-parser         # 10 parsing tests
pixi run test-arrays         # 14 array tests
pixi run test-tables         # 8 table header tests
pixi run test-inline         # 13 inline table tests
pixi run test-dotted-keys    # 7 dotted key tests
pixi run test-validation     # 7 error/duplicate detection tests
pixi run test-real-world     # 4 real TOML file tests
pixi run test-fixtures       # 5 complex config tests
pixi run test-parser-reset   # 3 API reusability tests

# Writer tests (41 total)
pixi run test-writer-basic      # 20 basic type serialisation tests
pixi run test-writer-tables     # 11 table structure tests
pixi run test-writer-roundtrip  # 10 round-trip fidelity tests
```

### Development
```bash
# Check Mojo version
pixi run mojo-version

# Run examples
pixi run example-quickstart  # Basic usage example
pixi run example-simple      # Comprehensive API demo
pixi run example-pixi        # Parse project's own pixi.toml
pixi run example-roundtrip   # Parse/modify/write workflow

# Build package
pixi run build-package       # Creates dist/toml.mojopkg

# Clean build artifacts
pixi run clean
```

### Running Individual Files
```bash
# Test files
mojo -I src tests/test_lexer.mojo

# Examples
mojo -I src examples/quickstart.mojo
```

**Important:** Always use `-I src` flag when running Mojo files to include the source directory.

## Architecture

### Three-Component Architecture

The library follows a classic compiler design with three independent components:

1. **Lexer (src/toml/lexer.mojo)** - Tokenisation
   - Converts raw TOML text into token stream
   - Handles string escapes, number formats, multiline strings
   - Tracks line/column positions for error messages
   - Key types: `Lexer`, `Token`, `TokenKind`, `Position`

2. **Parser (src/toml/parser.mojo)** - Structure Building
   - Consumes token stream and builds nested Dict structures
   - Implements TOML syntax rules (dotted keys, table headers, etc.)
   - Detects duplicate keys and validates structure
   - Key types: `Parser`, `TomlValue`, `TomlValueType`

3. **Writer (src/toml/writer.mojo)** - Serialisation
   - Converts `Dict[String, TomlValue]` to TOML string
   - Handles string escaping, array formatting, table headers
   - Smart inline table heuristic (0-1 keys use inline format)
   - Full round-trip support (parse → write → parse preserves semantics)
   - Key types: `Writer`, public function `to_toml()`

### Type System

`TomlValue` is a variant type that represents any TOML value:
- Primitive types: String, Int, Float64, Bool
- Composite types: List[TomlValue] (arrays), Dict[String, TomlValue] (tables)
- Uses discriminated union with type constants (TomlValueType.STRING, etc.)

**Critical:** Mojo is statically typed. Unlike Python's `tomli`, you must use explicit type conversions:
- `.as_string()`, `.as_int()`, `.as_float()`, `.as_bool()`
- `.as_array()`, `.as_table()`
- These methods raise errors if called on wrong type

### Key Design Patterns

1. **Separation of concerns**: Lexer, parser, and writer are completely independent
2. **Position tracking**: Every token knows its source location for error messages
3. **Nested structures**: Dotted keys (`a.b.c = "value"`) create nested Dict hierarchy
4. **Validation**: Parser detects duplicate keys at all nesting levels
5. **Reusability**: `Parser.reset()` allows reusing parser instance for multiple documents
6. **Round-trip fidelity**: Writer guarantees semantic equality after parse → write → parse

## Testing Strategy

Tests are organised by TOML feature (not file structure):
- **Feature isolation**: Arrays, tables, inline tables, and dotted keys each have dedicated test files
- **Validation separate**: Error detection tests kept separate from happy-path tests
- **Real-world coverage**: Includes parsing actual config files (pixi.toml, etc.)

When adding tests:
- Choose the correct test file based on feature being tested
- Keep tests focused on single behaviour
- Use descriptive test names
- Update test count in docs/TEST_ORGANIZATION.md

## Current Limitations

### Not Yet Implemented (v0.5.0+ roadmap)
- Array of tables: `[[section]]`
- Hex/octal/binary integers: `0xDEAD`, `0o755`, `0b1101`
- Native datetime parsing (currently returns ISO 8601 strings)
- INI file parser and writer

### Known Behaviour
- All parsing returns Dict[String, TomlValue], requiring explicit type conversions
- Datetime values are stored as strings (ISO 8601 format)
- Parser tracks line/column for errors but doesn't preserve comments

## Contributing Guidelines

### Code Style
- Use Australian English in documentation/comments
- Use US spelling for variable/function names (Mojo convention)
- Document "Why/What/How" in module docstrings (see lexer.mojo/parser.mojo)
- Keep functions focused and short

### Development Workflow
1. Write test first in appropriate test_*.mojo file
2. Run specific test suite during development: `pixi run test-<feature>`
3. Implement feature in lexer.mojo or parser.mojo
4. Validate with full test suite: `pixi run test-all`
5. Update CHANGELOG.md following existing format

### Error Messages
- Always include line/column context from Position
- Format: "Error at line X, column Y: <message>"
- Be specific about what was expected vs what was found

## Dependencies

- **Mojo**: Language runtime (via pixi)
- **tomli** (Python): Used only for validation testing, not required by library itself
- **pixi**: Project/environment manager (defined in pixi.toml)

The library has zero Python dependencies at runtime - pure Mojo implementation.

## Project Structure Notes

```
src/toml/
  __init__.mojo    # Public API: parse(), to_toml(), TomlValue
  lexer.mojo       # Token stream generation
  parser.mojo      # Structure building from tokens
  writer.mojo      # TOML serialisation

tests/
  test_*.mojo      # Organised by feature, not by source file
  dev/             # Experimental/debugging tests (not run by test-all)

examples/
  quickstart.mojo  # README example
  simple.mojo      # Comprehensive API usage
  parse_pixi.mojo  # Real-world example
  roundtrip.mojo   # Parse/modify/write workflow

fixtures/          # Test TOML files
docs/              # Technical documentation
  ROADMAP.md              # Development timeline
  TEST_ORGANIZATION.md    # Testing strategy
  PERFORMANCE.md          # Benchmarks
  TOML_WRITER_DESIGN.md   # Writer architecture
```

## Installation Methods

When helping users integrate this library:

1. **Git submodule** (recommended for projects):
   ```bash
   git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml
   mojo -I vendor/mojo-toml/src your_app.mojo
   ```

2. **Direct copy** (simplest):
   ```bash
   cp -r mojo-toml/src/toml your-project/lib/toml
   mojo -I your-project/lib your_app.mojo
   ```

3. **pixi package** (coming in future release)

## Version Information

Current version: v0.4.0 (January 2026)
- 137 comprehensive tests (96 parser + 41 writer)
- Complete TOML 1.0 parser support except array-of-tables and alternative number bases
- Full TOML writer with round-trip fidelity
- Production-ready for current feature set
- See CHANGELOG.md for version history
