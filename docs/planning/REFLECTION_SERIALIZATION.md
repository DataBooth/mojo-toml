# Reflection-Based Struct Serialization

## Overview

User suggestion: Use Mojo's reflection capabilities to automatically serialise/deserialise structs to/from TOML, eliminating the need for explicit `.as_string()`, `.as_int()`, etc. calls.

## Ideal API

```mojo
struct Config:
    var name: String
    var port: Int
    var debug: Bool
    var limits: Limits

struct Limits:
    var max_connections: Int
    var timeout: Float64

# Automatic serialisation
var config = from_toml[Config]("config.toml")  # Deserialise
var toml_str = to_toml(config)  # Serialise
```

## Current Reflection Capabilities (Mojo 2026-01)

Mojo's `reflection` module provides:

✅ **Available:**
- `get_type_name[T]()` - Get type names as strings
- `struct_field_count[T]()` - Count fields in a struct
- `struct_field_names[T]()` - Get field names (compile-time)
- `struct_field_types[T]()` - Get field types
- `struct_field_index_by_name[T]()` - Lookup field index
- `struct_field_type_by_name[T]()` - Lookup field type

❌ **Critical Limitations:**
- No runtime field value access (can get names, but not read/write values)
- No trait/interface querying
- No enum reflection
- Compile-time only operations
- Early-stage stability concerns

## Requirements for Auto-Serialisation

1. **Runtime field access** - Read/write field values dynamically
2. **Dynamic construction** - Build structs from parsed data
3. **Recursive handling** - Process nested structs automatically
4. **Type conversion** - Map TOML types to Mojo types safely
5. **Error handling** - Validate missing/invalid fields with good errors

## Assessment

### Not Ready for v0.6.0-0.7.0 ❌

**Blockers:**
1. Cannot access field values at runtime (critical)
2. Reflection API stability concerns
3. Unknown performance characteristics
4. API will evolve and break code

**Consensus:** Wait for reflection to mature before implementing.

## Interim Solution: Trait-Based Approach

Add a `Deserializable` trait that users implement manually:

```mojo
trait Deserializable:
    fn from_toml(data: Dict[String, TomlValue]) raises -> Self

trait Serializable:
    fn to_toml(self) -> Dict[String, TomlValue]

struct Config(Deserializable, Serializable):
    var name: String
    var port: Int
    var debug: Bool
    
    fn from_toml(data: Dict[String, TomlValue]) raises -> Config:
        return Config(
            name=data["name"].as_string(),
            port=data["port"].as_int(),
            debug=data["debug"].as_bool()
        )
    
    fn to_toml(self) -> Dict[String, TomlValue]:
        var result = Dict[String, TomlValue]()
        result["name"] = TomlValue(self.name)
        result["port"] = TomlValue(self.port)
        result["debug"] = TomlValue(self.debug)
        return result^

# Usage - cleaner than raw Dict access:
var data = parse(toml_content)
var config = Config.from_toml(data)
var toml_str = to_toml(config.to_toml())
```

**Benefits:**
- Reduces boilerplate
- Type-safe at struct definition
- Stable (no experimental features)
- Can be implemented now

**Drawbacks:**
- Still requires manual implementation per struct
- Not as ergonomic as automatic reflection

## Roadmap

### v0.6.0-0.7.0: Manual Trait Approach (Possible)
- Define `Deserializable` and `Serializable` traits
- Provide example implementations
- Document patterns in user guide
- Consider helper macros if Mojo gains macro support

### v0.8.0+: Automatic Reflection (When Ready)
- Automatic serialisation: `from_toml[T](str)`
- Automatic deserialisation: `to_toml(struct)`
- Type-safe config loading
- **Blocked on:** Runtime field access in Mojo reflection

**Status:** Tracking Mojo stdlib development

## References

- Mojo Reflection Docs: https://docs.modular.com/mojo/std/reflection/
- User discussion: v0.5.0 release feedback
- Related: serde in Rust, dataclasses in Python

## Decision

**Add to roadmap as future feature** - Excellent idea, but wait for Mojo reflection to mature. Consider trait-based interim solution for v0.6.0.
