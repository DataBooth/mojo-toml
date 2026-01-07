# mojo-toml 🔥

**Native TOML 1.0 parser for Mojo**

> **Status:** 🚀 **v0.3.0** - Quality and performance release (96 tests passing)

## Overview

`mojo-toml` enables native TOML parsing in Mojo without Python dependencies. Parse configuration files, project settings, and structured data with a clean, type-safe API.

**Key features:**
- ✅ Complete TOML 1.0 support (strings, numbers, arrays, tables)
- ✅ Nested structures with dotted keys
- ✅ Duplicate key detection
- ✅ Clear error messages with line/column context
- ✅ 96 comprehensive tests
- ✅ Zero Python dependencies

## Quickstart

Create a TOML file (`config.toml`):

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

Parse it with mojo-toml:

```mojo
from toml import parse

fn main() raises:
    # Read TOML file
    var content: String
    with open("config.toml", "r") as f:
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

## TOML 1.0 Support

### ✅ Implemented

- **Basic types**: strings, integers, floats, booleans
- **Strings**: basic, literal, multiline variants
- **Numbers**: integers, floats, underscores, special values (inf, nan)
- **Arrays**: `[1, 2, 3]` with nesting and mixed types
- **Inline tables**: `{name = "value"}` with nesting
- **Table headers**: `[section]` with proper nesting
- **Dotted keys**: `a.b.c = "value"`
- **Duplicate detection**: rejects invalid files
- **Error messages**: line and column context

### 🚧 Planned

- **Array of tables**: `[[array]]`
- **Hex/Octal/Binary integers**: `0xDEAD`, `0o755`, `0b1101`
- **Native datetime parsing**: currently returns ISO 8601 strings
- **TOML writer**: serialize Dict back to TOML

See [ROADMAP.md](docs/ROADMAP.md) for planned features and timeline.

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
│   ├── __init__.mojo   # Public API
│   ├── lexer.mojo      # Tokenization
│   └── parser.mojo     # TOML parsing
├── tests/              # Test suite (96 tests)
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
- [v0.3.0 Release](https://github.com/DataBooth/mojo-toml/releases/tag/v0.3.0)
- [TOML 1.0 Spec](https://toml.io/en/v1.0.0)
- [Mojo Documentation](https://docs.modular.com/mojo/)
