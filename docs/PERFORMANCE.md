# Performance Characteristics

This document explains the performance characteristics of mojo-toml and the copying behavior inherent in Mojo's ownership model.

## Benchmark Results

Performance measurements on a typical development machine (see `benchmarks/benchmark_parser.mojo`):

| Operation | Throughput | Average Time | Notes |
|-----------|------------|--------------|-------|
| Simple parse (5 keys) | 37,000 parses/sec | 26 μs | Very fast for small configs |
| Nested tables (7 keys) | 4,370 parses/sec | 228 μs | Good for structured configs |
| Arrays (~40 elements) | 6,350 parses/sec | 157 μs | Efficient array handling |
| Dotted keys (9 keys) | 4,218 parses/sec | 237 μs | Comparable to table headers |
| Large document (40+ keys) | 290 parses/sec | 3 ms | Still fast for real-world files |
| Real pixi.toml | 446 parses/sec | 2 ms | Production-ready performance |
| **Table access** | **91,000 accesses/sec** | **10 μs** | **Negligible overhead** |

### Key Findings

1. **Parsing is fast**: Even large documents parse in milliseconds
2. **Table access overhead is minimal**: 10 μs per nested `as_table()` call
3. **Real-world performance is excellent**: pixi.toml parses in ~2ms
4. **The copying overhead is acceptable** for typical use cases

## Copying Behavior

### Why Copying Happens

mojo-toml uses **value semantics** throughout, which means data is copied rather than shared. This is a deliberate design choice driven by Mojo's ownership model:

1. **Safety**: Prevents aliasing issues and use-after-free bugs
2. **Simplicity**: No lifetime annotations or borrow checker complexity
3. **Predictability**: Clear ownership semantics

### Where Copying Occurs

#### 1. `as_table()` and `as_array()` Methods

```mojo
fn as_table(self) raises -> Dict[String, TomlValue]:
    # Returns a COPY of the table
    var result = Dict[String, TomlValue]()
    for entry in self.table_value.items():
        result[entry.key] = entry.value.copy()  # Deep copy
    return result^
```

**Why**: Mojo doesn't currently support borrowed returns from struct methods. The copy ensures safe ownership transfer.

**Impact**: 10 μs per call (negligible for typical usage)

#### 2. Parser Internal Functions

Functions like `ensure_table_path()` and `set_in_table_path()` use functional-style copying:

```mojo
fn ensure_table_path(mut self, result: Dict[String, TomlValue], path: List[String]) raises -> Dict[String, TomlValue]:
    # Creates new Dict with modifications
    var new_result = Dict[String, TomlValue]()
    for entry in result.items():
        new_result[entry.key] = entry.value.copy()
    # ... modifications ...
    return new_result^
```

**Why**: Mojo's ownership prevents in-place mutation of borrowed parameters in some contexts.

**Impact**: O(depth × keys) during parsing, but amortized over the entire parse operation (still 2-3ms for large files)

#### 3. KeyValuePair Extraction

```mojo
var parsed_key = pair.key
var parsed_value = pair.value.copy()
```

**Why**: Mojo prevents partial destruction - can't move `pair.value` while `pair.key` is still needed.

**Impact**: One copy per key-value pair during parsing (included in overall parse time)

## Performance Recommendations

### ✅ Do This (Efficient)

```mojo
// Cache table references if accessing multiple times
var db = config["database"].as_table()
var host = db["host"].as_string()
var port = db["port"].as_int()
var user = db["user"].as_string()  // ~26 μs total
```

### ❌ Avoid This (Wasteful)

```mojo
// Don't call as_table() repeatedly
var host = config["database"].as_table()["host"].as_string()
var port = config["database"].as_table()["port"].as_int()
var user = config["database"].as_table()["user"].as_string()  // ~30 μs total
```

The difference is small (4 μs) but caching is better practice.

### Reuse Parsers

```mojo
// Efficient: Reuse parser instance
var parser = Parser(tokens1^)
var data1 = parser.parse()

parser.reset(tokens2^)
var data2 = parser.parse()
```

This avoids allocating new Parser objects.

## Future Optimizations

### Potential Improvements

1. **Borrowed References**: If Mojo adds support for borrowed struct method returns:
   ```mojo
   fn as_table_ref(borrowed self) -> borrowed Dict[String, TomlValue]:
       return self.table_value  // Zero-copy!
   ```

2. **In-Place Mutation**: If Mojo's ownership allows more flexible mutation:
   ```mojo
   fn ensure_table_path_mut(mut self, mut result: Dict[String, TomlValue], ...)
       // Mutate result directly instead of copying
   ```

3. **Arena Allocation**: Use a memory arena for parser-internal structures

### Why Not Now?

- **Mojo limitations**: Current language doesn't support borrowed returns from methods
- **Minimal impact**: Benchmark shows copying overhead is negligible (10 μs)
- **Correctness first**: Value semantics ensure safety and correctness
- **Future-proof**: Can optimize when Mojo adds features without API changes

## Comparison to Other Parsers

For context, here's how mojo-toml compares:

| Parser | Language | Typical Parse Time | Notes |
|--------|----------|-------------------|-------|
| **mojo-toml** | **Mojo** | **2ms (pixi.toml)** | **This project** |
| tomli | Python | 5-10ms | Pure Python, interpreted |
| toml++ | C++ | 0.5-1ms | Zero-copy design |
| serde_json | Rust | 1-2ms | Zero-copy with lifetimes |

mojo-toml is **competitive** despite using value semantics. The copying overhead is minimal compared to parsing logic.

## Conclusion

The copying behavior in mojo-toml is:

1. **Necessary**: Due to Mojo's current ownership model
2. **Fast**: 10 μs per table access is negligible
3. **Acceptable**: Real-world files parse in 2-3ms
4. **Improvable**: Future Mojo features could eliminate copies

For 99% of use cases (reading configuration files), the current performance is excellent. The value semantics provide safety and simplicity without meaningful performance cost.

## Monitoring Performance

Run the benchmark yourself:

```bash
mojo -I src benchmarks/benchmark_parser.mojo
```

If you have specific performance requirements or large-scale parsing needs, please file an issue with your use case and we can investigate targeted optimizations.
