# mojo-toml v0.4.0 - TOML Writer Release 🔥

**TL;DR:** mojo-toml now supports writing TOML files! Build configs programmatically and serialize to TOML format with full round-trip fidelity.

## What's New

v0.4.0 adds complete TOML serialization:

```mojo
from toml import to_toml, TomlValue

fn main() raises:
    // Build configuration
    var config = Dict[String, TomlValue]()
    
    var app = Dict[String, TomlValue]()
    app["name"] = TomlValue("MyApp")
    app["version"] = TomlValue("1.0.0")
    app["debug"] = TomlValue(True)
    config["app"] = TomlValue(app^)
    
    var db = Dict[String, TomlValue]()
    db["host"] = TomlValue("localhost")
    db["port"] = TomlValue(5432)
    config["database"] = TomlValue(db^)
    
    // Write to file
    var toml_str = to_toml(config)
    with open("config.toml", "w") as f:
        f.write(toml_str)
```

**Output:**
```toml
[app]
name = "MyApp"
version = "1.0.0"
debug = true
[database]
host = "localhost"
port = 5432
```

## Features

- ✅ `to_toml()` function for Dict → TOML string conversion
- ✅ All types: strings, integers, floats, booleans, arrays, tables
- ✅ String escaping, nested structures, table headers
- ✅ Round-trip verified: parse → modify → write → parse preserves semantics
- ✅ 41 new tests (137 total: 96 parser + 41 writer)

## Installation

**Git submodule:**
```bash
git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml
mojo -I vendor/mojo-toml/src your_app.mojo
```

**Direct copy:**
```bash
git clone https://github.com/databooth/mojo-toml
cp -r mojo-toml/src/toml your-project/lib/toml
mojo -I your-project/lib your_app.mojo
```

## Links

- **GitHub:** https://github.com/databooth/mojo-toml
- **Release:** https://github.com/DataBooth/mojo-toml/releases/tag/v0.4.0
- **Changelog:** Full details in CHANGELOG.md

## Roadmap

**v0.5.0:** Array of tables `[[section]]`, hex/octal/binary integers, INI support  
**v0.6.0:** Comparative Python benchmarks, memory profiling

---

Zero Python dependencies. Pure Mojo. MIT licensed.

Feedback and contributions welcome! 🚀
