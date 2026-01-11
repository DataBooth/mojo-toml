# mojo-toml v0.5.0 🎉

Major release completing the TOML 1.0 specification and adding partial TOML 1.1 support!

## What's New

### ✅ TOML 1.0 - Fully Complete
- **Array-of-tables** `[[section]]` syntax with full nesting support
- **Alternative number bases**: hex (`0xDEAD`), octal (`0o755`), binary (`0b1101`)
- All TOML 1.0 features now implemented

### 🔮 TOML 1.1 (Partial Support)
- `\xHH` escape sequences for codepoints 0-255
- `\e` escape for escape character (U+001B)

### 📊 Benchmark System
- Comprehensive performance testing with system info reporting
- Compare mojo-toml vs Python's tomllib/tomli_w
- Run with `pixi run benchmark-mojo` and `pixi run benchmark-python`
- Auto-generated markdown reports with full machine specifications

### 🧪 Testing
- **168 tests passing** (127 parser + 41 writer)
- Auto-discovery test runner
- Full test coverage for all TOML 1.0 features

## Performance

- Real-world config files (pixi.toml) parse in ~2ms
- 40K+ parses/sec for simple documents
- Negligible 10μs overhead per table access
- Competitive with Python implementations

## Installation

```bash
# Git submodule (recommended)
git submodule add https://github.com/databooth/mojo-toml vendor/mojo-toml
mojo -I vendor/mojo-toml/src your_app.mojo
```

See [README.md](../../README.md) for other installation methods.

## Documentation

- [CHANGELOG.md](../../CHANGELOG.md) - Full release notes with technical details
- [PERFORMANCE.md](../PERFORMANCE.md) - Performance analysis and benchmarking
- [docs/planning/](.) - Roadmap and design documentation

## Breaking Changes

None - this release is fully backward compatible with v0.4.0.

## Known Limitations

- Datetime values are returned as ISO 8601 strings (native Mojo datetime support pending)
- TOML 1.1 is only partially implemented (missing multiline inline tables and optional seconds)

## What's Next

See [ROADMAP.md](ROADMAP.md) for planned features in v0.6.0 and beyond.

## Links

- [GitHub Repository](https://github.com/databooth/mojo-toml)
- [TOML 1.0 Spec](https://toml.io/en/v1.0.0)
- [TOML Implementations Wiki](https://github.com/toml-lang/toml/wiki)
- [Mojo Documentation](https://docs.modular.com/mojo/)

## Contributors

This release was made possible by contributions from the Mojo community and DataBooth.

---

**Released:** 2026-01-11
**Tag:** v0.5.0
