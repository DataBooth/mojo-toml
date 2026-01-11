# mojo-toml v0.2.0 🔥

**The first native TOML 1.0 parser for the Mojo programming language!**

This release provides full TOML parsing with **proper nested table structures**. Thanks to feedback from the Modular Discord community, we discovered the correct Dict iteration pattern and implemented nested tables from the start!

## 🚀 What's New

### Core Parser - Fully Functional
- ✅ **79 tests passing** across 7 comprehensive test suites
- ✅ Parses real-world TOML files (including pixi.toml)
- ✅ Zero Python dependencies at runtime
- ✅ Clear error messages with line/column information

### Supported TOML Features
- Key-value pairs: `key = "value"`
- Comments: `# comment`
- Strings: basic, literal, multiline variants
- Numbers: integers, floats, special values (inf, nan)
- Booleans: `true`, `false`
- Arrays: `[1, 2, 3]` with nesting and mixed types
- Inline tables: `{name = "value"}` with nesting
- **Table headers: `[section]` with proper nested structures** ✨
- **Dotted headers: `[a.b.c]` with deep nesting** ✨
- Datetime strings (ISO 8601)

## 📦 Installation

### Recommended: Git Submodule
```bash
git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml
mojo -I vendor/mojo-toml/src your_app.mojo
```

### Alternative: Direct Copy
```bash
git clone https://github.com/databooth/mojo-toml
cp -r mojo-toml/src/toml your-project/lib/toml
mojo -I your-project/lib your_app.mojo
```

### Compiled Package
Download `toml.mojopkg` from this release (see compatibility note below).

## 💻 Usage Example

```mojo
from toml import parse

fn main() raises:
    var config = parse("""
        title = "MyApp"
        version = "1.0.0"
        
        [database]
        host = "localhost"
        port = 5432
    """)
    
    # Access root-level keys
    print(config["title"].as_string())  # "MyApp"
    
    # Access nested tables (proper structure!)
    var db = config["database"].as_table()
    print(db["host"].as_string())  # "localhost"
    print(db["port"].as_int())      # 5432
```

## 🎉 Major Feature: Nested Table Structures

Tables are now properly nested using Dict structures:

```mojo
# Simple nesting:
var db = config["database"].as_table()
var host = db["host"].as_string()

# Deep nesting:
# [database.primary]
var db = config["database"].as_table()
var primary = db["primary"].as_table()
var host = primary["host"].as_string()
```

This was made possible by discovering that Mojo's Dict iterator works with `entry.key` and `entry.value` directly!

## 🚧 Known Limitations

**Not yet implemented (planned for v0.3.0 - TOML 1.0 Compliance):**
- Array of tables: `[[array]]`
- Duplicate key detection
- Hex/Octal/Binary integers: `0xDEADBEEF`, `0o755`, `0b11010110`
- Dotted keys in standalone key-value pairs: `a.b.c = "value"`
- Native datetime parsing (currently returns ISO 8601 strings)

**Planned for v0.4.0+:**
- Writer/serialiser functionality

## 🧪 Testing

All 79 tests passing:
- 25 lexer tests
- 10 parser tests
- 4 real-world file tests
- 5 fixture tests
- 14 array tests
- 13 inline table tests
- 8 table header tests

Run tests yourself:
```bash
git clone https://github.com/databooth/mojo-toml
cd mojo-toml
pixi install
pixi run test-all
```

## 📚 Documentation

- [README.md](https://github.com/databooth/mojo-toml/blob/main/README.md) - Complete usage guide
- [CHANGELOG.md](https://github.com/databooth/mojo-toml/blob/main/CHANGELOG.md) - Detailed change history
- [docs/TABLE_HEADERS_BLOCKER.md](https://github.com/databooth/mojo-toml/blob/main/docs/TABLE_HEADERS_BLOCKER.md) - Technical explanation of flat key limitation
- [TOML 1.0 Spec](https://toml.io/en/v1.0.0) - Official specification

## 🔧 Compatibility

- **Mojo Version:** Tested with Mojo 2025/2026 (via pixi)
- **Platforms:** macOS (Apple Silicon), Linux
- **Python:** Zero dependencies for runtime

⚠️ **`.mojopkg` Compatibility Note**: The compiled package is built with the Mojo version shown in the build artifacts. It may not work with different Mojo versions. Source installation is recommended for maximum compatibility.

## 🗺️ Roadmap

### v0.3.0 (Next) - TOML 1.0 Compliance
- Array of tables: `[[array]]`
- Duplicate key detection
- Hex/Octal/Binary integers
- Dotted keys in key-value pairs
- Native datetime types
- Enhanced error messages

### v0.4.0
- SIMD optimisations
- Performance benchmarks
- Advanced optimizations

## 🙏 Acknowledgements

Built with inspiration from:
- [Python tomli](https://github.com/hukkin/tomli) - Reference implementation
- [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Proven parser patterns
- [TOML Specification](https://toml.io/en/v1.0.0) - Excellent config format by Tom Preston-Werner

## 💬 Feedback & Support

- **Issues:** [GitHub Issues](https://github.com/databooth/mojo-toml/issues)
- **Discussions:** [Modular Discord](https://discord.gg/modular) - #mojo channel
- **Sponsor:** This project is sponsored by [DataBooth](https://www.databooth.com.au)

---

**Full Changelog:** See [CHANGELOG.md](https://github.com/databooth/mojo-toml/blob/main/CHANGELOG.md) for complete details.
