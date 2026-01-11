# mojo-toml 🔥

**Native TOML 1.0 parser and writer for Mojo**

> **Status:** 🚀 **v0.5.0** - TOML 1.0 Complete + Partial 1.1 (168 tests passing)

## Overview

`mojo-toml` enables native TOML parsing in Mojo without Python dependencies. Parse configuration files, project settings, and structured data with a clean, type-safe API.

**Key features:**
- ✅ **TOML 1.0 compliant** - full specification support
- ✅ **Array of tables** - `[[section]]` syntax for repeated table arrays
- ✅ **Alternative number bases** - hex (`0xDEAD`), octal (`0o755`), binary (`0b1101`)
- ✅ **TOML writer** - serialize Dict back to TOML format with round-trip fidelity
- ✅ **Nested structures** - dotted keys and table headers
- ✅ **168 comprehensive tests** - parser (127) + writer (41)
- ✅ **Zero Python dependencies** - pure native Mojo implementation

## Quickstart

Create a TOML file (e.g `examples/quickstart.toml`):

```toml
# Application configuration
[app]
name = "QuickStart"
version = "1.0.0"
debug = false

[database]
host = "localhost"
port = 5432
timeout = 30.5

[features]
enabled = ["auth", "logging", "metrics"]
```

### Reading TOML

Parse it with mojo-toml:

```mojo
from toml import parse

fn main() raises:
    # Read TOML file
    var content: String
    with open("examples/quickstart.toml", "r") as f:
        content = f.read()
    
    # Parse and access values
    var config = parse(content)
    
    # Access nested tables
    var app = config["app"].as_table()
    print("App:", app["name"].as_string())
    print("Version:", app["version"].as_string())
    
    var db = config["database"].as_table()
    print("Database:", db["host"].as_string(), ":", db["port"].as_int())
    print("Timeout:", db["timeout"].as_float())
    
    # Access arrays
    var features = config["features"].as_table()["enabled"].as_array()
    print("Features enabled:", len(features))
```

### Writing TOML

Create configuration programmatically and write to TOML:

```mojo
from toml import to_toml, TomlValue

fn main() raises:
    # Build configuration using Dict and TomlValue
    var config = Dict[String, TomlValue]()
    
    # Create app section
    var app = Dict[String, TomlValue]()
    app["name"] = TomlValue("QuickStart")
    app["version"] = TomlValue("2.0.0")
    app["debug"] = TomlValue(True)
    config["app"] = TomlValue(app^)
    
    # Create database section
    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("localhost")
    db["port"] = TomlValue(5432)
    db["timeout"] = TomlValue(30.5)
    config["database"] = TomlValue(db^)
    
    # Create features array
    var enabled = List[TomlValue]()
    enabled.append(TomlValue("auth"))
    enabled.append(TomlValue("logging"))
    enabled.append(TomlValue("metrics"))
    var features = Dict[String, TomlValue]()
    features["enabled"] = TomlValue(enabled^)
    config["features"] = TomlValue(features^)
    
    # Convert to TOML and write to file
    var toml_str = to_toml(config)
    with open("output.toml", "w") as f:
        f.write(toml_str)
    
    print("Configuration written to output.toml")
```

**Note for Python users:** Unlike Python's `tomli` where you access values directly (`config["app"]["name"]`), mojo-toml requires explicit type conversions (`.as_table()`, `.as_string()`, etc.) because Mojo is statically typed. This provides type safety and clear error messages at the cost of slightly more verbose code.

**Try it yourself:** This example is available as `examples/quickstart.mojo`. Run it with:
```bash
pixi run example-quickstart
```

## Installation

Choose the installation method that best fits your workflow:

### Option 1: Git Submodule (Recommended)

Best for version-controlled projects with easy updates.

```bash
# Add to your project
cd your-project
git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml

# Use in your code
mojo -I vendor/mojo-toml/src your_app.mojo

# Update to latest version
git submodule update --remote vendor/mojo-toml
```

### Option 2: Direct Copy

Simplest method for quick projects.

```bash
# Clone and copy source
git clone https://github.com/databooth/mojo-toml
cp -r mojo-toml/src/toml your-project/lib/toml

# Use in your code
mojo -I your-project/lib your_app.mojo
```

### Option 3: pixi (Coming Soon)

```bash
# Future installation method via modular-community channel
pixi add mojo-toml
```

## TOML Specification Compliance

### ✅ TOML 1.0 - Fully Compliant

**mojo-toml implements the complete TOML 1.0 specification** (https://toml.io/en/v1.0.0):

- **Basic types**: strings, integers, floats, booleans
- **Strings**: basic, literal, multiline (both basic and literal)
- **Numbers**: integers, floats, underscores, special values (inf, nan)
- **Alternative number bases**: hex (`0xDEAD`), octal (`0o755`), binary (`0b1101`) ✨ *v0.5.0*
- **Arrays**: `[1, 2, 3]` with nesting and mixed types
- **Inline tables**: `{name = "value"}` with nesting
- **Table headers**: `[section]` with proper nesting
- **Array of tables**: `[[section]]` for repeated table arrays ✨ *v0.5.0*
- **Dotted keys**: `a.b.c = "value"` creating nested structures
- **Duplicate detection**: validates and rejects duplicate keys
- **Error messages**: precise line and column context
- **TOML writer**: serialize `Dict[String, TomlValue]` to TOML format
- **Round-trip support**: parse → modify → write → parse preserves semantic equality

**Date/Time values:** Parsed and validated according to TOML 1.0, returned as ISO 8601 strings. Native Mojo datetime objects are not yet used due to ongoing standard library development. This does not affect TOML parsing correctness or round-trip fidelity.

### 🔮 TOML 1.1 (Partial Support)

TOML 1.1 features implemented:
- ✅ `\\xHH` escape sequences for codepoints 0-255 (e.g., `\\x00`, `\\x61`)
- ✅ `\\e` escape for escape character (U+001B)

TOML 1.1 features not yet implemented:
- Multiline inline tables with trailing commas
- Optional seconds in datetime/time values

See [ROADMAP.md](docs/ROADMAP.md) for development timeline.

## Development

### Prerequisites
- Mojo 2025/2026 (via pixi)
- Python 3.10+ (for validation tests)

### Setup
```bash
# Clone repository
git clone https://github.com/databooth/mojo-toml
cd mojo-toml

# Install dependencies
pixi install

# Run tests
pixi run test-all

# Run examples
pixi run example-simple
pixi run example-pixi
```

### Project Structure

```
mojo-toml/
├── src/toml/           # Source code
│   ├── __init__.mojo   # Public API: parse(), to_toml()
│   ├── lexer.mojo      # Tokenisation
│   ├── parser.mojo     # TOML parsing
│   └── writer.mojo     # TOML serialisation
├── tests/              # Test suite (163 tests)
├── examples/           # Usage examples
├── benchmarks/         # Performance benchmarks
├── fixtures/           # Test TOML files
├── docs/               # Documentation
│   ├── ROADMAP.md      # Development roadmap
│   ├── PERFORMANCE.md  # Performance characteristics
│   └── ...
└── packaging/          # Conda packaging files
```

## Documentation

- [ROADMAP.md](docs/ROADMAP.md) - Development roadmap and planned features
- [PERFORMANCE.md](docs/PERFORMANCE.md) - Performance benchmarks and characteristics
- [TEST_ORGANIZATION.md](docs/TEST_ORGANIZATION.md) - Test structure and guidelines
- [TOML_WRITER_DESIGN.md](docs/TOML_WRITER_DESIGN.md) - Writer implementation design
- [CHANGELOG.md](CHANGELOG.md) - Version history and changes

## Contributing

Contributions welcome! This project is open source (MIT License).

**How to contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `pixi run test-all` to ensure tests pass
5. Submit a pull request

See [ROADMAP.md](docs/ROADMAP.md) for areas where contributions would be most valuable.

## Acknowledgements

Special thanks to:
- **[DataBooth](https://www.databooth.com.au/posts/mojo)** - Project sponsor, building high-performance data and AI services with Mojo
- **[Python tomli](https://github.com/hukkin/tomli)** - Reference implementation for validation
- **[TOML Specification](https://toml.io/en/v1.0.0)** - Tom Preston-Werner's excellent config format
- **Modular Team** - For creating the Mojo programming language

## License

MIT License - See [LICENSE](LICENSE) for details.

## Links

- [GitHub Repository](https://github.com/databooth/mojo-toml)
- [Latest Release](https://github.com/databooth/mojo-toml/releases)
- [TOML 1.0 Spec](https://toml.io/en/v1.0.0)
- [TOML Implementations List](https://github.com/toml-lang/toml/wiki)
- [Mojo Documentation](https://docs.modular.com/mojo/)
