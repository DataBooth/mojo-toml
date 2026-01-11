# Project Overview

Build the first native TOML 1.0 parser for the Mojo programming language ecosystem. This fills a critical infrastructure gap—Mojo projects extensively use TOML for configuration (pixi.toml, mojoproject.toml) but must rely on Python interop to parse these files. Creating a native parser benefits the entire community and enables pure-Mojo tooling.

# Current State

**No TOML parser exists in the Mojo ecosystem:**
- Confirmed via awesome-mojo, Modular stdlib, and modular-community recipes
- Existing parsers: CSV, JSON, FASTQ
- Current workaround: Python interop with `tomli`
- Repository created: https://github.com/DataBooth/mojo-toml

**Available reference implementation:**
- mojo-dotenv provides proven parser architecture (character-by-character parsing, escape handling, string processing)
- Can validate against Python `tomli` library for correctness

# Technical Design

## Architecture

Follow proven mojo-dotenv pattern with three-layer architecture:

**Layer 1: Lexer** (`lexer.mojo`)
- Tokenise TOML input into stream of tokens
- Token types: KEY, VALUE, TABLE, ARRAY, STRING, INTEGER, FLOAT, BOOLEAN, DATETIME, WHITESPACE, COMMENT, NEWLINE, EQUALS, BRACKET, BRACE, COMMA, DOT
- Handle escape sequences in strings
- Track line/column positions for error messages

**Layer 2: Parser** (`parser.mojo`)
- Convert token stream into structured data
- Build nested Dict[String, Value] structure
- Validate TOML 1.0 syntax rules
- Handle dotted keys (a.b.c = value)
- Process table headers [section] and array tables [[array]]
- Detect duplicate keys (TOML spec requirement)

**Layer 3: Public API** (`__init__.mojo`)
- `parse(content: String) -> Dict[String, Value]` - Parse TOML string
- `load(path: Path) -> Dict[String, Value]` - Parse TOML file
- `loads(content: String) -> Dict[String, Value]` - Alias for parse
- `TomlError` - Custom error type with line/column info

## Data Structure

TOML values map to Mojo types:
- String → `String`
- Integer → `Int`
- Float → `Float64`
- Boolean → `Bool`
- Datetime → `String` (ISO 8601 format, v0.1.0)
- Array → `List[Value]`
- Table → `Dict[String, Value]`

Use variant/union type for `Value`:
```mojo
struct Value:
    var data: Variant[String, Int, Float64, Bool, List[Value], Dict[String, Value]]
```

## TOML 1.0 Features (v0.1.0 Scope)

**Core syntax:**
- [x] Key-value pairs: `key = "value"`
- [x] Comments: `# comment`
- [x] Basic strings: `"hello"`
- [x] Literal strings: `'raw string'`
- [x] Multiline basic strings: `"""text"""`
- [x] Multiline literal strings: `'''text'''`
- [x] Integers: `42`, `+17`, `-5`, `1_000`
- [x] Floats: `3.14`, `1e10`, `6.022e23`
- [x] Booleans: `true`, `false`
- [x] Datetime: `1979-05-27T07:32:00Z` (parse as string v0.1.0)
- [x] Arrays: `[1, 2, 3]`
- [x] Inline tables: `{name = "value"}`
- [x] Tables: `[section]`
- [x] Array of tables: `[[array]]`
- [x] Dotted keys: `a.b.c = "value"`
- [x] Duplicate key detection

**Out of scope for v0.1.0:**
- Native datetime parsing (return ISO 8601 string)
- Writer/serialiser functionality
- Schema validation
- Custom formatting

# Testing Strategy

## Validation Approach

Use Python `tomli` as reference implementation:
```mojo
from python import Python

fn test_parser() raises:
    let content = Path("test.toml").read_text()
    
    # Mojo implementation
    let mojo_result = parse(content)
    
    # Python reference
    let py = Python.import_module("tomli")
    let py_result = py.loads(content)
    
    # Compare results
    assert_equal(mojo_result, py_result)
```

## Test Suite Structure

- `tests/test_basic.mojo` - Basic key-value pairs
- `tests/test_strings.mojo` - All string types and escapes
- `tests/test_numbers.mojo` - Integer and float parsing
- `tests/test_arrays.mojo` - Array syntax and nesting
- `tests/test_tables.mojo` - Table headers and nesting
- `tests/test_inline.mojo` - Inline tables
- `tests/test_datetime.mojo` - Datetime formats
- `tests/test_errors.mojo` - Invalid TOML detection
- `tests/test_tomli_compat.mojo` - Validate against tomli
- `tests/test_spec.mojo` - TOML 1.0 spec compliance

## Test Files

Use real-world TOML files:
- `fixtures/pixi.toml` - Mojo project config
- `fixtures/mojoproject.toml` - Mojo package config
- `fixtures/cargo.toml` - Rust project (stress test)
- `fixtures/pyproject.toml` - Python project
- `fixtures/spec_examples.toml` - TOML spec examples

# Implementation Phases

## Phase 1: Foundation (Week 1)

**Goal:** Project structure + basic lexer

**Tasks:**
- Initialise pixi project with dependencies
- Create src/toml/ module structure
- Implement lexer with basic token types
- Write lexer tests
- Set up CI/CD with GitHub Actions

**Deliverables:**
- Tokeniser handles basic TOML syntax
- 20+ lexer tests passing
- README with project vision

## Phase 2: Core Parser (Week 2)

**Goal:** Parse basic TOML to Dict

**Tasks:**
- Implement parser for key-value pairs
- Handle strings (basic, literal, multiline)
- Parse numbers (int, float)
- Parse booleans and arrays
- Implement dotted key expansion

**Deliverables:**
- Parse simple TOML files
- 30+ parser tests passing
- Validate against tomli

## Phase 3: Tables & Nesting (Week 3)

**Goal:** Complete TOML 1.0 compliance

**Tasks:**
- Implement table headers [section]
- Handle array of tables [[array]]
- Detect duplicate keys
- Parse inline tables
- Handle datetime strings
- Complete error messages

**Deliverables:**
- Full TOML 1.0 spec compliance
- 50+ tests passing
- Parse pixi.toml and mojoproject.toml

## Phase 4: Polish & Documentation (Week 4)

**Goal:** Production-ready release

**Tasks:**
- Performance optimisation
- Comprehensive error messages
- API documentation
- Usage examples
- Blog post: "Building Mojo's First TOML Parser"
- Submit to awesome-mojo
- Create modular-community recipe

**Deliverables:**
- v0.1.0 release
- Complete documentation
- Package published

# Distribution Plan

## Phase 1: GitHub Repository

- Source code on DataBooth/mojo-toml
- Release v0.1.0 with .mojopkg binary
- Installation via git submodule or direct copy

## Phase 2: Community Listing

- Submit to awesome-mojo curated list
- Create recipe for modular-community channel
- Users install via: `pixi add mojo-toml`

## Phase 3: Ecosystem Integration

- Blog post series
- Demo projects using mojo-toml
- Integration examples with Mojo tooling

# Success Criteria

- ✅ Parse all valid TOML 1.0 files
- ✅ Reject all invalid TOML (per spec)
- ✅ 100% pass rate against tomli test suite
- ✅ Parse pixi.toml and mojoproject.toml correctly
- ✅ Clear error messages with line/column info
- ✅ Published to modular-community
- ✅ Adopted by 3+ projects in community

# Future Roadmap

## v0.2.0 - Writer

- Serialise Dict to TOML string
- Pretty printing options
- Round-trip fidelity (parse → write → parse)

## v0.3.0 - Performance

- SIMD optimisations for parsing
- Benchmarks vs Python tomli
- Memory efficiency improvements

## v0.4.0 - Advanced Features

- Schema validation
- Custom datetime parsing
- Streaming parser for large files
- Error recovery mode

# References

- TOML 1.0 Spec: https://toml.io/en/v1.0.0
- Python tomli: https://github.com/hukkin/tomli
- mojo-dotenv architecture: https://github.com/databooth/mojo-dotenv
- Rust toml crate: https://docs.rs/toml/latest/toml/
- Go toml library: https://github.com/BurntSushi/toml
