# TOML Writer Design

This document outlines the design for implementing a TOML writer (serializer) for mojo-toml.

## Overview

A TOML writer converts Mojo data structures (Dict, List, etc.) back into valid TOML format strings. This enables:
- Configuration generation
- Round-trip parsing (read → modify → write)
- Data export to TOML format
- Testing and validation

## Core Requirements

### 1. Basic Type Serialization

**Simple Types:**
```mojo
# Input: Dict with basic values
var config = Dict[String, TomlValue]()
config["name"] = TomlValue("mojo-toml")
config["port"] = TomlValue(8080)
config["enabled"] = TomlValue(true)
config["ratio"] = TomlValue(3.14)

# Output:
# name = "mojo-toml"
# port = 8080
# enabled = true
# ratio = 3.14
```

**Implementation needs:**
- String escaping (quotes, newlines, tabs, special chars)
- Integer formatting (handle underscores as option?)
- Float formatting (handle scientific notation, inf, nan)
- Boolean formatting (true/false)

### 2. Array Serialization

**Simple arrays:**
```mojo
var arr = List[TomlValue]()
arr.append(TomlValue(1))
arr.append(TomlValue(2))
arr.append(TomlValue(3))

# Output: [1, 2, 3]
```

**Nested arrays:**
```mojo
# Output: [[1, 2], [3, 4]]
```

**Mixed-type arrays:**
```mojo
# Output: [1, "two", 3.0, true]
```

**Implementation needs:**
- Comma separation
- Whitespace handling (compact vs. pretty)
- Multiline array formatting (for readability)
- Nested structure handling

### 3. Table Serialization

**Simple tables:**
```mojo
# Output:
# [database]
# host = "localhost"
# port = 5432
```

**Nested tables:**
```mojo
# Output:
# [database.primary]
# host = "localhost"
# 
# [database.replica]
# host = "replica.example.com"
```

**Implementation needs:**
- Table header generation
- Dotted key notation vs table headers (choose appropriate format)
- Proper nesting and hierarchy
- Key ordering (alphabetical? preserve insertion order?)

### 4. Inline Tables

```mojo
# Output: point = { x = 1, y = 2 }
```

**Implementation needs:**
- Single-line formatting
- When to use inline vs. regular tables (heuristic needed)
- Nested inline tables

### 5. Special Cases

**Multiline strings:**
```toml
description = """
This is a long
multiline description.
"""
```

**Literal strings:**
```toml
path = 'C:\Users\name'
```

**Special float values:**
```toml
pos_inf = inf
neg_inf = -inf
not_a_number = nan
```

## Design Options

### Option 1: Functional Approach

```mojo
fn to_toml(config: Dict[String, TomlValue]) raises -> String:
    """Convert Dict to TOML string."""
    var result = String("")
    
    # Separate keys into root keys and tables
    var root_keys = List[String]()
    var table_keys = List[String]()
    
    for entry in config.items():
        if entry.value.is_table():
            table_keys.append(entry.key)
        else:
            root_keys.append(entry.key)
    
    # Write root keys first
    for key in root_keys:
        result += format_key_value(key, config[key])
    
    # Write tables
    for key in table_keys:
        result += format_table(key, config[key].as_table())
    
    return result
```

### Option 2: Builder Pattern

```mojo
struct TomlWriter:
    var buffer: String
    var indent_level: Int
    var options: WriterOptions
    
    fn write_value(mut self, key: String, value: TomlValue) raises:
        """Write a key-value pair."""
        pass
    
    fn write_table(mut self, name: String, table: Dict[String, TomlValue]) raises:
        """Write a table section."""
        pass
    
    fn to_string(self) -> String:
        """Get the final TOML string."""
        return self.buffer
```

**Usage:**
```mojo
var writer = TomlWriter()
writer.write_value("name", TomlValue("app"))
writer.write_table("database", db_config)
var toml_string = writer.to_string()
```

### Option 3: Formatter Classes

```mojo
struct ValueFormatter:
    """Formats individual values."""
    
    fn format_string(self, s: String) -> String:
        """Format string with proper escaping."""
        pass
    
    fn format_array(self, arr: List[TomlValue]) -> String:
        """Format array."""
        pass

struct TableFormatter:
    """Formats tables and hierarchies."""
    
    fn format_table_header(self, path: List[String]) -> String:
        """Format [table.name] header."""
        pass
```

## Implementation Complexity

### Easy (1-2 days)
- ✅ Basic type formatting (strings, numbers, booleans)
- ✅ Simple key-value pairs
- ✅ Simple arrays
- ✅ Basic string escaping

### Medium (3-5 days)
- 📊 Table formatting and hierarchy
- 📊 Nested structures
- 📊 Array of tables
- 📊 Inline table detection (when to use)
- 📊 Multiline string handling

### Hard (5-7 days)
- 🔴 Round-trip fidelity (preserve comments, formatting)
- 🔴 Pretty printing with configurable options
- 🔴 Optimal table vs. dotted key selection
- 🔴 Key ordering strategies
- 🔴 Performance optimisation

## Proposed API

### Simple API (v1)

```mojo
fn to_toml(config: Dict[String, TomlValue]) raises -> String:
    """Convert Dict to TOML string with default formatting."""
    pass
```

### Configurable API (v2)

```mojo
struct TomlWriterOptions:
    var indent_size: Int = 2
    var use_inline_tables: Bool = true
    var multiline_array_threshold: Int = 3
    var sort_keys: Bool = false
    var preserve_order: Bool = true

fn to_toml(
    config: Dict[String, TomlValue],
    options: TomlWriterOptions = TomlWriterOptions()
) raises -> String:
    """Convert Dict to TOML with custom options."""
    pass
```

## Testing Strategy

### Unit Tests
1. Each type serialization (strings, ints, floats, bools)
2. String escaping (quotes, newlines, tabs, unicode)
3. Array formatting (simple, nested, mixed)
4. Table formatting (simple, nested, dotted)
5. Inline tables
6. Special values (inf, nan, multiline strings)

### Round-Trip Tests
```mojo
fn test_round_trip() raises:
    """Parse TOML → convert back → should match original semantics."""
    var original_toml = """
        name = "test"
        port = 8080
        [database]
        host = "localhost"
    """
    
    var parsed = parse(original_toml)
    var serialized = to_toml(parsed)
    var reparsed = parse(serialized)
    
    # Values should be identical
    assert parsed["name"].as_string() == reparsed["name"].as_string()
    # Note: formatting may differ, but semantics should match
```

### Real-World Tests
- Serialize pixi.toml and verify it can be re-parsed
- Test with complex nested configurations
- Ensure TOML spec compliance

## Implementation Order

### Phase 1: Basic Writer (MVP)
1. Value formatters (strings, numbers, booleans)
2. Simple key-value serialization
3. Simple arrays
4. Basic tables (one level)
5. Unit tests for above

**Estimated: 3-5 days**

### Phase 2: Complete Writer
1. Nested tables and hierarchy
2. Dotted keys
3. Inline tables
4. Array of tables
5. Comprehensive tests

**Estimated: 5-7 days**

### Phase 3: Pretty Printing
1. Writer options
2. Formatting choices
3. Key ordering
4. Multiline formatting
5. Comment preservation (stretch goal)

**Estimated: 3-5 days**

## Challenges

### 1. Table Hierarchy
Deciding when to use:
```toml
# Option A: Dotted keys
database.host = "localhost"
database.port = 5432

# Option B: Table headers
[database]
host = "localhost"
port = 5432
```

**Solution:** Use heuristics:
- If table has 1-2 keys → dotted keys
- If table has 3+ keys → table header
- Allow configuration via options

### 2. Key Ordering
Mojo Dict may not preserve insertion order. Options:
- Sort keys alphabetically
- Use separate ordered structure
- Accept any order (simplest)

### 3. String Escaping
Must handle all TOML escape sequences:
- `\n` (newline)
- `\t` (tab)  
- `\"` (quote)
- `\\` (backslash)
- `\uXXXX` (unicode)

### 4. Float Precision
How to format floats to preserve precision while being readable?

## Example Implementation Sketch

```mojo
fn to_toml(config: Dict[String, TomlValue]) raises -> String:
    var writer = String("")
    
    # Write non-table values first
    for entry in config.items():
        if not entry.value.is_table():
            writer += format_key_value(entry.key, entry.value)
            writer += "\n"
    
    # Write tables
    for entry in config.items():
        if entry.value.is_table():
            writer += "\n[" + entry.key + "]\n"
            var table = entry.value.as_table()
            for table_entry in table.items():
                writer += format_key_value(table_entry.key, table_entry.value)
                writer += "\n"
    
    return writer

fn format_key_value(key: String, value: TomlValue) raises -> String:
    var result = key + " = "
    
    if value.is_string():
        result += "\"" + escape_string(value.as_string()) + "\""
    elif value.is_int():
        result += String(value.as_int())
    elif value.is_float():
        result += String(value.as_float())
    elif value.is_bool():
        result += "true" if value.as_bool() else "false"
    elif value.is_array():
        result += format_array(value.as_array())
    elif value.is_table():
        result += format_inline_table(value.as_table())
    
    return result
```

## Conclusion

A TOML writer is definitely feasible! The MVP (Phase 1) could be implemented in **3-5 days** with:
- Basic type serialization
- Simple structures
- Good test coverage

The complete implementation (Phases 1-2) would take approximately **8-12 days** total, providing a fully-featured TOML writer that handles all TOML 1.0 features.

## Next Steps

1. Implement Phase 1 (MVP) with basic functionality
2. Add comprehensive tests
3. Get community feedback
4. Iterate on formatting options and edge cases
5. Add pretty printing features

Would be a great addition to mojo-toml for v0.4.0 or v0.5.0!
