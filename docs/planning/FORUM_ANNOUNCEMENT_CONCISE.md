# mojo-toml v0.3.0 - Native TOML Parser

I've released **mojo-toml**, a native TOML 1.0 parser for Mojo with zero Python dependencies.

## What it does

Parses TOML configuration files into native Mojo structures:
- All TOML 1.0 types (strings, integers, floats, booleans, arrays, tables)
- Nested structures with dotted keys
- Duplicate key detection
- Clear error messages with line/column context
- 96 tests ensuring reliability

## Installation

```bash
git clone https://github.com/DataBooth/mojo-toml.git
cd mojo-toml
pixi run test-all
```

Coming soon to the `modular-community` channel.

## Usage

```mojo
from toml import parse

fn main() raises:
    var config = parse("""
        [database]
        host = "localhost"
        port = 5432
    """)
    
    var db = config["database"].as_table()
    print(db["host"].as_string())  # "localhost"
    print(db["port"].as_int())     # 5432
```

## What's in v0.3.0

- Proper dotted key support and duplicate detection
- Parser improvements with `reset()` method
- Reorganised test suite (96 tests across 10 files)
- Performance benchmarks and documentation

See the [CHANGELOG](https://github.com/DataBooth/mojo-toml/blob/main/CHANGELOG.md) for full details.

## Links

- [GitHub Repository](https://github.com/DataBooth/mojo-toml)
- [v0.3.0 Release](https://github.com/DataBooth/mojo-toml/releases/tag/v0.3.0)
- [Documentation](https://github.com/DataBooth/mojo-toml/blob/main/README.md)
- License: MIT

## Roadmap

Planned features for future releases:
- TOML writer (serialiser)
- Array of tables `[[array]]`
- Hex/octal/binary integers
- Native datetime parsing

## Acknowledgements

This project is sponsored by [DataBooth](https://www.databooth.com.au/posts/mojo), building high-performance data and AI services with Mojo.

Feedback and contributions welcome!
