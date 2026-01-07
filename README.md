# mojo-toml 🔥

**The first native TOML 1.0 parser for the Mojo programming language.**

> **Status:** 🚧 **In Development** - Phase 1: Foundation

## Overview

`mojo-toml` enables Mojo projects to parse TOML configuration files natively, without Python interop. This fills a critical infrastructure gap in the Mojo ecosystem—every Mojo project uses TOML for configuration (`pixi.toml`, `mojoproject.toml`), but until now, parsing required Python's `tomli` library.

```mojo
from toml import parse, load
from pathlib import Path

fn main() raises:
    # Parse TOML string
    var config = parse("""
        [database]
        host = "localhost"
        port = 5432
    """)
    
    # Load TOML file
    var project = load(Path("pixi.toml"))
    print("Project:", project["workspace"]["name"])
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

### v0.1.0 - Parser (Current)
- [x] Project structure and dependencies
- [ ] Lexer (tokenisation)
- [ ] Parser (key-value pairs, strings, numbers, booleans)
- [ ] Tables and nested structures
- [ ] Array support
- [ ] TOML 1.0 spec compliance
- [ ] Test suite with `tomli` validation

### v0.2.0 - Writer
- [ ] Serialise `Dict` to TOML string
- [ ] Pretty printing options
- [ ] Round-trip fidelity

### v0.3.0 - Performance
- [ ] SIMD optimisations
- [ ] Benchmarks vs Python `tomli`

See [PLAN.md](docs/PLAN.md) for detailed technical design.

## Installation

> **Note:** Installation methods will be available after v0.1.0 release.

**Option 1: pixi (Recommended - After v0.1.0)**
```bash
pixi add mojo-toml
```

**Option 2: Git Submodule**
```bash
git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml
mojo -I vendor/mojo-toml/src your_app.mojo
```

**Option 3: Direct Copy**
```bash
git clone https://github.com/databooth/mojo-toml
cp -r mojo-toml/src/toml your-project/lib/toml
mojo -I your-project/lib your_app.mojo
```

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

`mojo-toml` targets full TOML 1.0 compliance:

**v0.1.0 Features:**
- [x] Key-value pairs: `key = "value"`
- [x] Comments: `# comment`
- [x] Strings (basic, literal, multiline)
- [x] Numbers (integers, floats, underscores)
- [x] Booleans: `true`, `false`
- [x] Arrays: `[1, 2, 3]`
- [x] Inline tables: `{name = "value"}`
- [x] Tables: `[section]`
- [x] Array of tables: `[[array]]`
- [x] Dotted keys: `a.b.c = "value"`
- [x] Datetime strings (ISO 8601)
- [x] Duplicate key detection
- [x] Clear error messages

**Out of scope for v0.1.0:**
- Native datetime parsing (returns ISO 8601 string)
- Writer/serialiser functionality

## Contributing

Contributions welcome! This is an open-source project (MIT License).

**Current Focus:** Phase 1 - Foundation
- Implementing lexer
- Setting up test infrastructure
- Establishing CI/CD

See [PLAN.md](docs/PLAN.md) for implementation details.

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
