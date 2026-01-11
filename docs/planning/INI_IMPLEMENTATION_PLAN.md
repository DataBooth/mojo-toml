# INI File Reader/Writer Implementation Plan

## Overview
Implement INI file parsing and writing capabilities as an extension to mojo-toml. INI is a simpler, more permissive format than TOML that shares the same section-based structure. This enables legacy config file support and broader compatibility.

## Context: INI vs TOML

### Key Differences
- **Type system**: INI is untyped (everything is strings by default), TOML has explicit types
- **Quoting**: INI allows unquoted strings, TOML requires quotes for strings
- **Arrays**: INI has no standard array syntax, TOML has `[1, 2, 3]`
- **Nested tables**: INI doesn't support nesting, TOML does via `[a.b.c]`
- **Comments**: INI uses `;` or `#`, TOML uses only `#`
- **Specification**: INI has many dialects, TOML has one formal spec
- **Simplicity**: INI is simpler and more forgiving, TOML is stricter and more expressive

### What INI Provides
```ini
; This is a comment
# Also a comment

[Section]
key = value
name = John Doe
port = 8080
enabled = true

[Database]
host = localhost
user = admin
```

### Architectural Relationship
INI is essentially a simplified subset of TOML:
- Can reuse lexer concepts (tokenisation)
- Can reuse value type infrastructure (TomlValue)
- Simpler parser (no arrays, no nesting)
- Simpler writer (no type formatting decisions)

## Prerequisites
- TOML writer must be complete (v0.5.0)
- TOML parser infrastructure is stable
- TomlValue type is well-tested

**Target Release:** v0.6.0 (Q2-Q3 2026)

**Total Estimate:** 11-17 days for complete INI support

See full implementation plan in this document for detailed phases, architecture decisions, and success criteria.
