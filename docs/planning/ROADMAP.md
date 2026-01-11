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

### v0.4.0 - TOML 1.0 Compliance
**Target:** Q1 2026

**Features:**
- [ ] Array of tables: `[[array]]`
- [ ] Hex/Octal/Binary integers: `0xDEAD`, `0o755`, `0b1101`
- [ ] Native datetime parsing (currently returns ISO 8601 strings)
- [ ] Additional spec compliance edge cases

**Estimated Effort:** 5-7 days

### v0.5.0 - Writer/Serialiser
**Target:** Q2 2026

**Features:**
- [ ] Basic writer: `to_toml(Dict) -> String`
- [ ] String escaping and formatting
- [ ] Array and table serialisation
- [ ] Round-trip testing (parse → write → parse)

See [TOML_WRITER_DESIGN.md](TOML_WRITER_DESIGN.md) for detailed design.

**Estimated Effort:**
- MVP: 3-5 days
- Complete: 8-12 days

### v0.6.0 - Pretty Printing
**Target:** Q2 2026

**Features:**
- [ ] Configurable writer options
- [ ] Key ordering strategies
- [ ] Multiline array formatting
- [ ] Comment preservation (stretch goal)

**Estimated Effort:** 3-5 days

### v0.7.0 - Performance Optimisations
**Target:** Q3 2026

**Features:**
- [ ] SIMD optimisations for parsing
- [ ] String processing optimisations
- [ ] Benchmarks vs Python tomli
- [ ] Performance profiling tools

**Estimated Effort:** 7-10 days

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
