# mojo-toml 🔥

**The first native TOML 1.0 parser for the Mojo programming language.**

> **Status:** 🚀 **v0.2.0** - Full TOML parser with nested tables (79 tests passing)

## Overview

`mojo-toml` enables Mojo projects to parse TOML configuration files natively, without Python interop. This fills a critical infrastructure gap in the Mojo ecosystem—every Mojo project uses TOML for configuration (`pixi.toml`, `mojoproject.toml`), but until now, parsing required Python's `tomli` library.

```mojo
from toml import parse

fn main() raises:
    # Parse TOML string
    var config = parse("""
        title = "MyApp"
        version = "1.0.0"
        
        [database]
        host = "localhost"
        port = 5432
    """)
    
    # Access root-level keys directly
    print(config["title"].as_string())  # "MyApp"
    
    # Access nested table values
    var db = config["database"].as_table()
    print(db["host"].as_string())  # "localhost"
    print(db["port"].as_int())      # 5432
```

## Why mojo-toml?

**Problem:** Mojo projects extensively use TOML for configuration, but:
- No native TOML parser exists in the Mojo ecosystem
- Current workaround requires Python interop with `tomli`
- Pure-Mojo tooling cannot parse project configuration files

**Solution:** `mojo-toml` provides a native, TOML 1.0-compliant parser that:
- ✅ Parses all valid TOML 1.0 files
- ✅ Zero Python dependencies
- ✅ Validated against Python `tomli` for correctness
- ✅ Clear error messages with line/column info

## Roadmap

### v0.2.0 - Nested Tables (Current)
- [x] Project structure and dependencies
- [x] Lexer (tokenisation) - 540 lines, handles all TOML tokens
- [x] Parser (key-value pairs, strings, numbers, booleans)
- [x] Array support (nested, mixed types)
- [x] Inline tables `{key = "value"}`
- [x] Table headers `[section]` with **proper nested structures**
- [x] Dotted table headers `[a.b.c]` with nesting
- [x] Test suite - 79 tests passing
- [ ] Array of tables `[[array]]`
- [ ] Duplicate key detection
- [ ] Full TOML 1.0 spec compliance

### v0.1.0 - Foundation (Skipped)
- Originally planned with flat key storage
- Jumped directly to v0.2.0 after Discord community feedback enabled nested tables

### v0.3.0 - TOML 1.0 Compliance
- [ ] Array of tables: `[[array]]` for repeated sections
- [ ] Duplicate key detection (reject invalid files)
- [ ] Hex/Octal/Binary integers: `0xDEAD`, `0o755`, `0b1101`
- [ ] Dotted keys in key-value pairs: `a.b.c = "value"`
- [ ] Native datetime parsing (vs ISO 8601 strings)
- [ ] Enhanced error messages with context

### v0.4.0 - Writer
- [ ] Serialise `Dict` to TOML string
- [ ] Pretty printing options
- [ ] Round-trip fidelity

### v0.5.0 - Performance
- [ ] SIMD optimisations
- [ ] Benchmarks vs Python tomli

See [PLAN.md](docs/PLAN.md) for detailed technical design.

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

### Option 3: Compiled Package (.mojopkg)

Pre-compiled packages available from [GitHub Releases](https://github.com/databooth/mojo-toml/releases).

```bash
# Download from releases
curl -L -o toml.mojopkg https://github.com/databooth/mojo-toml/releases/latest/download/toml.mojopkg

# Use in your code
mojo -I . your_app.mojo  # Ensure toml.mojopkg is in import path
```

⚠️ **Note**: `.mojopkg` files are tied to specific Mojo versions. Check the release notes for compatibility. Source installation is recommended for maximum compatibility.

### Option 4: pixi (Coming Soon)

```bash
# Future installation method
pixi add mojo-toml
```

> Once this project is submitted to the modular-community channel, pixi will be the preferred installation method.

## Development

### Prerequisites
- Mojo 2025/2026 (via pixi)
- Python 3.10+ (for `tomli` validation)

### Setup
```bash
# Clone repository
git clone https://github.com/databooth/mojo-toml
cd mojo-toml

# Install dependencies
pixi install

# Run tests (after implementation)
pixi run test-all

# Run example
pixi run example-simple
```

## Project Structure

```
mojo-toml/
├── src/toml/           # Source code
│   ├── __init__.mojo   # Public API
│   ├── lexer.mojo      # Tokenisation
│   └── parser.mojo     # TOML parsing
├── tests/              # Test suite
├── examples/           # Usage examples
├── fixtures/           # Test TOML files
├── docs/               # Documentation
│   └── PLAN.md         # Technical design
├── pixi.toml           # Project configuration
├── LICENSE             # MIT License
└── README.md           # This file
```

## TOML 1.0 Support

`mojo-toml` targets full TOML 1.0 compliance. Current status:

**✅ Implemented (v0.1.0):**
- [x] Key-value pairs: `key = "value"`
- [x] Comments: `# comment`
- [x] Strings (basic, literal, multiline)
- [x] Numbers (integers, floats, underscores, special values)
- [x] Booleans: `true`, `false`
- [x] Arrays: `[1, 2, 3]` with nesting and mixed types
- [x] Inline tables: `{name = "value"}` with nesting
- [x] Table headers: `[section]` using flat key storage
- [x] Dotted table headers: `[a.b.c]`
- [x] Datetime strings (ISO 8601)
- [x] Clear error messages with line/column info

**✅ Nested Table Support:**

Tables are now properly nested using Dict structures:
```mojo
# TOML input:
# [database]
# host = "localhost"
# port = 5432

# Access nested tables:
var db = config["database"].as_table()
var host = db["host"].as_string()
var port = db["port"].as_int()

# Or for deeply nested tables:
# [database.primary]
var db = config["database"].as_table()
var primary = db["primary"].as_table()
var host = primary["host"].as_string()
```

**🚧 Not Yet Implemented (v0.3.0):**
- [ ] Array of tables: `[[array]]`
- [ ] Duplicate key detection
- [ ] Hex/Octal/Binary integers: `0xDEAD`, `0o755`, `0b1101`
- [ ] Dotted keys: `a.b.c = "value"` (works in tables, not standalone)
- [ ] Native datetime parsing (currently returns ISO 8601 string)

**🚧 Not Yet Implemented (v0.4.0+):**
- [ ] Writer/serialiser functionality
## Contributing

Contributions welcome! This is an open-source project (MIT License).

**Current Focus:** v0.3.0 - TOML 1.0 Compliance
- Array of tables `[[array]]`
- Duplicate key detection
- Hex/Octal/Binary integer support
- Dotted keys in key-value pairs
- Native datetime types
- Better error messages

**How to contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `pixi run test-all` to ensure tests pass
5. Submit a pull request

See [PLAN.md](docs/PLAN.md) for implementation details and [CHANGELOG.md](CHANGELOG.md) for roadmap.

## Sponsorship

This project is sponsored by **[DataBooth](https://www.databooth.com.au)** — Data analytics consulting for medium-sized businesses.

DataBooth transforms raw data into actionable strategies that drive growth, reduce costs, and manage emerging risks. Bringing risk expertise refined through quantitative finance, regulatory roles (APRA/ASIC), and hands-on AI development to help organisations make informed, data-driven decisions.

*Need help with data analytics, risk management, or evaluating Mojo for your infrastructure? [Let's talk](https://www.databooth.com.au/about/).*

## Acknowledgements

This project builds on excellent prior work:

- **[Python tomli](https://github.com/hukkin/tomli)** - Reference implementation for validation
- **[mojo-dotenv](https://github.com/databooth/mojo-dotenv)** - Proven parser architecture pattern
- **[TOML Specification](https://toml.io/en/v1.0.0)** - Tom Preston-Werner's excellent config format
- **Modular Team** - For creating the Mojo programming language

## License

MIT License - See [LICENSE](LICENSE) for details.

## Links

- [GitHub Repository](https://github.com/databooth/mojo-toml)
- [Technical Plan](docs/PLAN.md)
- [TOML 1.0 Spec](https://toml.io/en/v1.0.0)
- [Mojo Documentation](https://docs.modular.com/mojo/)
