# Test Organization

This document describes how tests are organized in the mojo-toml project.

## Test Files and Their Purpose

### Lexer Tests
- **test_lexer.mojo** (25 tests) - Lexer/tokenization tests
  - Tests token generation from TOML syntax
  - Covers strings, numbers, booleans, comments, punctuation
  - Tests basic syntax recognition (not full parsing)

### Parser Tests  
- **test_parser.mojo** (10 tests) - Core parser functionality
  - Tests value parsing (strings, integers, floats, booleans)
  - Tests key parsing variations
  - Tests comment handling during parsing

### Structure Tests
- **test_arrays.mojo** (14 tests) - Array parsing
  - Empty, single-element, and multi-element arrays
  - Nested arrays and mixed-type arrays
  - Trailing commas and whitespace handling

- **test_inline.mojo** (13 tests) - Inline table parsing
  - Inline table syntax: `{key = "value"}`
  - Nested inline tables
  - Arrays of inline tables

- **test_tables.mojo** (8 tests) - Table header parsing
  - Table headers: `[section]`
  - Nested table headers: `[a.b.c]`
  - Multiple tables and table combinations

- **test_dotted_keys.mojo** (7 tests) - Dotted key syntax
  - Dotted keys: `a.b.c = "value"`
  - Multiple dotted keys building nested structures
  - Dotted keys with different value types
  - Dotted keys combined with table headers

### Validation Tests
- **test_validation.mojo** (7 tests) - Error detection and validation
  - Duplicate key detection (root, table, nested)
  - Invalid syntax detection
  - Unsupported features (array of tables)
  - Type conflicts (redefining table as value)

### Real-World Tests
- **test_real_world.mojo** (4 tests) - Real TOML file parsing
  - pixi.toml parsing
  - Config files with comments
  - Multiline strings
  - Number variations

- **test_fixtures.mojo** (5 tests) - Complex example documents
  - Application config
  - Build config
  - ML config
  - API config
  - Game settings

### API Tests
- **test_parser_reset.mojo** (3 tests) - Parser reusability
  - Simple reset
  - Complex document reset
  - Multiple resets

### Writer Tests
- **test_writer_basic.mojo** (20 tests) - Basic type serialisation
  - Primitive types: strings, integers, floats, booleans
  - String escaping: backslash, quotes, newlines, tabs
  - Arrays: empty, simple, nested, mixed types
  - Inline tables: empty, single key, multiple keys

- **test_writer_tables.mojo** (11 tests) - Table structures
  - Table headers: simple, nested, multiple sections
  - Inline table heuristic (0-1 keys)
  - Nested table serialisation
  - Mixed inline and section headers

- **test_writer_roundtrip.mojo** (10 tests) - Round-trip fidelity
  - Parse → write → parse preserves semantic equality
  - Complex nested structures
  - Real-world file round-trip (pixi.toml)
  - Empty and edge cases

## Test Organization Principles

### 1. Grouping by Feature
Tests are grouped by the TOML feature they test:
- ✅ Arrays together
- ✅ Inline tables together
- ✅ Table headers together
- ✅ Dotted keys together

### 2. Separation of Concerns
- **Lexer tests** (test_lexer.mojo) focus on tokenization
- **Parser tests** (test_parser.mojo) focus on parsing logic
- **Structure tests** focus on specific TOML constructs
- **Validation tests** focus on error detection

### 3. Clear Naming
- File names indicate what is being tested
- Test function names are descriptive
- Tests within a file are related to the file's purpose

### 4. No Cross-Contamination
- Dotted key tests don't include validation tests
- Validation tests don't duplicate structure tests
- Each file has a single, clear purpose

## Running Tests

### Run All Tests
```bash
pixi run test-all
```

### Run Individual Test Suites
```bash
# Parser tests (96 total)
pixi run test-lexer          # Lexer tests
pixi run test-parser         # Parser tests
pixi run test-arrays         # Array tests
pixi run test-tables         # Table header tests
pixi run test-inline         # Inline table tests
pixi run test-dotted-keys    # Dotted key tests
pixi run test-validation     # Validation/error tests
pixi run test-real-world     # Real file tests
pixi run test-fixtures       # Complex example tests
pixi run test-parser-reset   # Parser reset tests

# Writer tests (41 total)
pixi run test-writer-basic      # Basic type serialisation
pixi run test-writer-tables     # Table structures
pixi run test-writer-roundtrip  # Round-trip fidelity
```

## Test Count Summary

| Category | File | Tests |
|----------|------|-------|
| **Parser Tests** | | **96** |
| Lexer | test_lexer.mojo | 25 |
| Parser | test_parser.mojo | 10 |
| Real-World | test_real_world.mojo | 4 |
| Fixtures | test_fixtures.mojo | 5 |
| Arrays | test_arrays.mojo | 14 |
| Inline Tables | test_inline.mojo | 13 |
| Table Headers | test_tables.mojo | 8 |
| Dotted Keys | test_dotted_keys.mojo | 7 |
| Validation | test_validation.mojo | 7 |
| Parser API | test_parser_reset.mojo | 3 |
| **Writer Tests** | | **41** |
| Basic Types | test_writer_basic.mojo | 20 |
| Table Structures | test_writer_tables.mojo | 11 |
| Round-Trip | test_writer_roundtrip.mojo | 10 |
| **Total** | **13 files** | **137 tests** |

## Adding New Tests

When adding new tests, follow these guidelines:

1. **Determine the category**: Is it a new feature, validation, or enhancement to existing feature?
2. **Choose the right file**: Put tests where they logically belong
3. **If creating a new file**: 
   - Use descriptive name: `test_<feature>.mojo`
   - Add to pixi.toml test tasks
   - Update this document
4. **Keep tests focused**: Each test should verify one specific behavior
5. **Name clearly**: Test names should describe what they verify

## Maintenance

This organization should be maintained as the project evolves:
- Don't mix unrelated tests in the same file
- Split files if they grow too large (>20 tests)
- Keep related tests together
- Update this document when adding new test files
