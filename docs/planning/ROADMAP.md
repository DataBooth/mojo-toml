# Roadmap

This document outlines the development roadmap for mojo-toml.

## Version History

### v0.3.0 - Quality & Performance (2026-01-07) ✅
- ✅ Proper dotted key support
- ✅ Duplicate key detection
- ✅ Enhanced error messages with line/column context
- ✅ Named type constants (replaced magic numbers)
- ✅ Parser.reset() method for reusability
- ✅ Test reorganisation (96 tests across 10 files)
- ✅ Performance benchmarks and documentation

### v0.2.0 - Nested Tables (2026-01-07) ✅
- ✅ Full nested table structures
- ✅ Dotted table headers `[a.b.c]`
- ✅ Proper Dict navigation
- ✅ 79 tests passing

### v0.1.0 - Foundation
Skipped - jumped directly to v0.2.0 after community feedback enabled nested tables.

## Planned Features

### v0.5.0 - TOML 1.0 Complete + Partial 1.1 (2026-01-11) ✅
- ✅ Array of tables: `[[section]]` with full nesting
- ✅ Hex/Octal/Binary integers: `0xDEAD`, `0o755`, `0b1101`
- ✅ TOML writer with round-trip support
- ✅ Partial TOML 1.1: `\xHH` and `\e` escape sequences
- ✅ Comprehensive benchmark system with machine info
- ✅ 168 tests passing (127 parser + 41 writer)

### v0.4.0 - TOML Writer (2026-01-08) ✅
- ✅ Complete TOML writer implementation
- ✅ String escaping and formatting
- ✅ Array and table serialisation
- ✅ Round-trip fidelity (parse → write → parse)
- ✅ 137 tests passing

### v0.6.0 - Remaining TOML 1.1
**Target:** Q1 2026

**Features:**
- [ ] Multiline inline tables with trailing commas
- [ ] Optional seconds in datetime/time values
- [ ] Complete TOML 1.1 compliance

**Estimated Effort:** 3-5 days

### v0.7.0 - Type-Safe Config (Trait-Based)
**Target:** Q2 2026

**Features:**
- [ ] `Deserializable` trait for struct conversion
- [ ] `Serializable` trait for struct serialisation
- [ ] Example implementations and patterns
- [ ] Documentation for manual struct mapping

**Estimated Effort:** 3-5 days

See [REFLECTION_SERIALIZATION.md](REFLECTION_SERIALIZATION.md) for analysis.

### v0.8.0+ - Automatic Struct Serialisation (Future)
**Target:** TBD (Blocked on Mojo reflection maturity)

**Features:**
- [ ] Automatic serialisation: `from_toml[T](str)`
- [ ] Automatic deserialisation: `to_toml(struct)`
- [ ] Type-safe config loading without manual mapping
- [ ] Nested struct support

**Blockers:**
- Runtime field value access in Mojo reflection
- Stable reflection API
- Dynamic struct construction

**Status:** Tracking Mojo stdlib development. See [REFLECTION_SERIALIZATION.md](REFLECTION_SERIALIZATION.md).

**Estimated Effort:** 7-10 days (after blockers resolved)

## Long-Term Vision

### Package Distribution
- [x] GitHub releases
- [ ] modular-community conda channel
- [ ] Official Mojo package registry (when available)

### Documentation
- [x] README with examples
- [x] API documentation
- [x] Performance documentation
- [ ] Tutorial series
- [ ] Video walkthroughs

### Community
- [ ] Example applications showcase
- [ ] Integration with popular Mojo projects
- [ ] Contributor guidelines
- [ ] Code of conduct

### Testing
- [x] Comprehensive test suite (96 tests)
- [x] Real-world file parsing
- [ ] TOML spec compliance test suite
- [ ] Fuzzing tests
- [ ] Property-based testing

## Contributing

See specific version plans for areas where contributions would be most valuable. Current priority is **v0.4.0** (TOML 1.0 compliance).

For implementation details, see:
- [TOML_WRITER_DESIGN.md](TOML_WRITER_DESIGN.md) - Writer implementation
- [PERFORMANCE.md](PERFORMANCE.md) - Performance characteristics
- [TEST_ORGANIZATION.md](TEST_ORGANIZATION.md) - Test structure

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **Major (1.0.0)**: Breaking API changes
- **Minor (0.x.0)**: New features, backward compatible
- **Patch (0.0.x)**: Bug fixes

Current pre-1.0 status indicates the API may still evolve based on community feedback.
