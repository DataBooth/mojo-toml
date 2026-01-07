# Development Tests

This directory contains test files used during development and debugging. These tests are not part of the main test suite but are kept for reference and future debugging.

## Nested Tables Implementation Tests

- `test_dict_iteration.mojo` - Verified that Dict iteration works without `[]` operator (entry.key, entry.value)
- `test_nested_dict.mojo` - Tested nested Dict structure building with TomlValue
- `test_parser_nested.mojo` - Integration test for nested table parsing

## Earlier Development Tests

- `test_both.mojo` - Early test during parser development
- `test_exact.mojo` - Early test during parser development  
- `test_multi.mojo` - Early test during parser development

## Running These Tests

```bash
# Nested table tests
pixi run mojo -I src tests/dev/test_dict_iteration.mojo
pixi run mojo -I src tests/dev/test_nested_dict.mojo
pixi run mojo -I src tests/dev/test_parser_nested.mojo

# Early development tests (may be outdated)
pixi run mojo tests/dev/test_both.mojo
pixi run mojo tests/dev/test_exact.mojo
pixi run mojo tests/dev/test_multi.mojo
```

## Historical Context

### Nested Tables Breakthrough

Initially, the parser used flat key storage (e.g., `"database.host"`) due to an apparent Dict iteration limitation. Community feedback on Discord revealed that `entry.key` and `entry.value` work directly without subscripting, which allowed us to implement proper nested structures.

The tests in this directory document this discovery and the path to the final implementation.

## Note

These tests are preserved for:
- Historical reference
- Future debugging
- Understanding the implementation evolution
- Demonstrating solutions to common Mojo patterns
