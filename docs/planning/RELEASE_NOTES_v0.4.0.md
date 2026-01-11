## v0.4.0 - TOML Writer Release 🔥

mojo-toml now supports both reading **and** writing TOML files with full round-trip fidelity!

### ✨ New Features

**TOML Writer:**
- `to_toml()` function - serialise `Dict[String, TomlValue]` to TOML string
- Complete type support: strings, integers, floats, booleans, arrays, tables
- String escaping, array formatting, table headers
- Smart inline table heuristic (0-1 keys use inline format)
- Full round-trip support: parse → write → parse preserves semantic equality

**Example:**
```mojo
from toml import to_toml, TomlValue

var config = Dict[String, TomlValue]()
var app = Dict[String, TomlValue]()
app["name"] = TomlValue("MyApp")
app["version"] = TomlValue("1.0.0")
config["app"] = TomlValue(app^)

var toml_str = to_toml(config)
with open("config.toml", "w") as f:
    f.write(toml_str)
```

### 🧪 Testing

- **20 new basic type serialisation tests**
- **11 new table structure tests**
- **10 new round-trip fidelity tests**
- **Critical:** pixi.toml successfully round-trips
- **Total: 137 tests** (96 parser + 41 writer)

### 📚 Documentation

- Updated README with read & write quickstart examples
- Created `docs/TOML_WRITER_DESIGN.md` - implementation architecture
- Updated WARP.md, TEST_ORGANIZATION.md, CHANGELOG.md
- New `examples/roundtrip.mojo` demonstrating parse/modify/write workflow
- Updated `examples/quickstart.mojo` with both reading and writing

### 🔧 Technical Details

**Writer Architecture:**
- 390-line `src/toml/writer.mojo` implementation
- String escaping: `\\`, `\"`, `\n`, `\t`, `\r`
- Recursive nested table serialisation
- Conservative inline table heuristic for readable output

**Files Added:**
- `src/toml/writer.mojo`
- `tests/test_writer_basic.mojo`
- `tests/test_writer_tables.mojo`
- `tests/test_writer_roundtrip.mojo`
- `examples/roundtrip.mojo`
- `docs/TOML_WRITER_DESIGN.md`
- `benchmarks/PLAN.md`

### 📦 Installation

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

### 🗺️ What's Next

**v0.5.0:** TOML 1.0 completion - array of tables `[[section]]`, hex/octal/binary integers  
**v0.6.0:** Comparative Python benchmarks, memory profiling  
**Future:** Separate mojo-ini package for INI file support

---

**Full Changelog:** https://github.com/DataBooth/mojo-toml/blob/main/CHANGELOG.md

Zero Python dependencies. Pure Mojo. MIT licensed.
