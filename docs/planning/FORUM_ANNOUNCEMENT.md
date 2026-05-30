# 🔥 Announcing mojo-toml v0.3.0 - Native TOML Parser for Mojo
> Historical forum post for the v0.3.0 release.
> Rework version numbers, feature counts, and roadmap items before reusing for newer releases.

I'm excited to share **mojo-toml** - the first native TOML 1.0 parser for Mojo! Parse configuration files with zero Python dependencies and blazing-fast performance.

## 🚀 What is mojo-toml?

mojo-toml enables Mojo developers to read TOML configuration files natively, perfect for:
- Application configuration
- Build systems (like pixi.toml!)
- Project settings
- Any structured data needs

## ✨ Key Features

### Complete TOML 1.0 Support
- ✅ All basic types: strings, integers, floats, booleans
- ✅ Arrays with nesting and mixed types
- ✅ Inline tables: `{key = "value"}`
- ✅ Table headers: `[section]`
- ✅ Nested tables: `[a.b.c]`
- ✅ Dotted keys: `a.b.c = "value"`
- ✅ Comments and multiline strings

### Quality & Reliability
- ✅ **96 comprehensive tests** across 10 test files
- ✅ Duplicate key detection
- ✅ Clear error messages with line/column context
- ✅ Successfully parses real-world files (tested with pixi.toml)

### Performance
- ⚡ **26 microseconds** for simple documents
- ⚡ **2 milliseconds** for real pixi.toml files
- ⚡ **10 microseconds** table access overhead (negligible!)

## 📦 Installation

### Option 1: Via Pixi (when available in modular-community)
```toml
# pixi.toml
[project]
channels = ["conda-forge", "https://conda.modular.com/max", "https://repo.prefix.dev/modular-community"]

[dependencies]
mojo-toml = "*"
```

### Option 2: Direct from GitHub
```bash
git clone https://github.com/DataBooth/mojo-toml.git
cd mojo-toml
pixi run test-all  # Verify installation
```

## 🎯 Quick Example

```mojo
from toml import parse

fn main() raises:
    # Parse TOML string
    var config = parse("""
        [database]
        host = "localhost"
        port = 5432
        
        [app]
        name = "my-app"
        debug = true
    """)
    
    # Access nested values
    var db = config["database"].as_table()
    print("Host:", db["host"].as_string())
    print("Port:", db["port"].as_int())
    
    var app = config["app"].as_table()
    print("App:", app["name"].as_string())
    print("Debug:", app["debug"].as_bool())
```

## 📊 What's New in v0.3.0

This release brings major quality and performance improvements:

### Critical Fixes
- ✅ Proper dotted key support (creates nested structures)
- ✅ Duplicate key detection with clear errors
- ✅ Enhanced error messages with line/column context
- ✅ Named type constants (replaced magic numbers)

### Parser Improvements
- 🔄 `Parser.reset()` method for instance reusability
- 🛠️ Helper methods and better code organization
- 📝 Enhanced documentation

### Testing & Documentation
- 📁 Reorganized into 10 logical test suites
- 📊 Comprehensive performance benchmarks
- 📚 New performance and test organization guides
- 🎨 Enhanced examples with detailed reporting

## 🔬 Under the Hood

Built entirely in native Mojo with:
- Custom lexer for tokenisation (25 tests)
- Recursive descent parser (10 core tests)
- Zero Python dependencies
- Proper nested Dict structures
- Comprehensive error handling

## 🎓 Learn More

- **GitHub**: https://github.com/DataBooth/mojo-toml
- **Latest Release**: https://github.com/DataBooth/mojo-toml/releases/tag/v0.3.0
- **Documentation**: See README.md and docs/ directory
- **Tests**: 96 tests demonstrating all features

## 🤝 Contributing

Contributions welcome! The project follows:
- Clear test organisation (see docs/TEST_ORGANIZATION.md)
- Comprehensive testing (96 tests and growing)
- Performance documentation (see docs/PERFORMANCE.md)

## 📝 Roadmap

Future enhancements planned:
- Array of tables: `[[array]]`
- Hex/Octal/Binary integers
- Native datetime parsing
- TOML writer/serialiser
- SIMD optimisations

## 💬 Feedback Welcome

This is a community project and I'd love to hear:
- How you're using it
- Feature requests
- Bug reports
- Performance feedback

Try it out and let me know what you think! 🚀

---

**Links:**
- GitHub: https://github.com/DataBooth/mojo-toml
- Release: https://github.com/DataBooth/mojo-toml/releases/tag/v0.3.0
- License: MIT

*Built with ❤️ for the Mojo community*
