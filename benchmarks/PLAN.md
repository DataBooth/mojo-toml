# Benchmarking Strategy for mojo-toml

## Current State (v0.4.0)

**Existing Benchmark: `benchmark_parser.mojo`**
- Internal performance testing of mojo-toml parser
- Measures parsing speed across different TOML patterns:
  - Simple key-value pairs (5 keys)
  - Nested tables (3 tables, 7 keys)
  - Arrays (4 arrays, ~40 elements)
  - Dotted keys (9 keys creating nested structures)
  - Large documents (8 tables, 40+ keys)
  - Table access overhead (nested `.as_table()` calls)
  - Real-world file (pixi.toml)

**Current Results:**
- Simple parse: ~26 μs (37,000 parses/sec)
- Nested tables: ~228 μs (4,370 parses/sec)
- Large documents: ~3 ms (290 parses/sec)
- Real pixi.toml: ~2 ms (446 parses/sec)
- Table access: ~10 μs (negligible overhead)

**Key Insight:** Performance is already excellent for typical config files (< 10KB). Most users won't need further optimisations.

## Planned Benchmarks for v0.6.0

### 1. Comparative Python Benchmarks (Highest Priority)

**Goal:** Demonstrate Mojo's practical speed advantage over Python's `tomli`/`tomllib`.

**Implementation:**
```bash
benchmarks/
  compare_python.mojo    # Mojo benchmark driver
  compare_python.py      # Python equivalent using tomli
  run_comparison.sh      # Shell script to run both and compare
```

**Benchmark Suite:**
- Parse identical TOML files with both implementations
- Measure:
  - Cold start time (first parse)
  - Warm time (repeated parses)
  - Memory usage (if possible)
- Files to test:
  - Small: basic config (< 1KB)
  - Medium: pyproject.toml, Cargo.toml (1-10KB)
  - Large: comprehensive config (10-100KB)
  - Real-world: pixi.toml, popular project configs

**Output Format:**
```
File: pixi.toml (2.3 KB)
  Python (tomli):  5.2 ms
  Mojo (mojo-toml): 2.1 ms
  Speedup: 2.5x faster
```

**Value:** Shows concrete advantage for real applications. Answers "Why use Mojo?"

### 2. Real-World Performance Tests

**Goal:** Measure performance with actual project configuration files.

**Test Files:**
- `pyproject.toml` from popular Python projects (poetry, black, mypy)
- `Cargo.toml` from Rust projects
- `pixi.toml` from Modular projects
- Build system configs (CMake, Meson)
- Application configs (VSCode settings, etc.)

**Metrics:**
- Parse time
- File size
- Complexity (number of tables, keys, arrays)
- Parses per second

**Output:** Performance table showing mojo-toml handles real configs efficiently.

### 3. Memory Profiling

**Goal:** Understand allocation patterns and memory usage.

**Approach:**
- Track Dict/List allocations during parsing
- Measure peak memory usage
- Compare with Python's memory overhead
- Document copying behaviour (Mojo ownership model)

**Questions to Answer:**
- How much memory per parsed key?
- Impact of nested structures?
- Memory efficiency vs Python?

**Value:** Important for embedded/constrained environments.

### 4. Writer Benchmarks

**Goal:** Measure serialisation performance.

**Tests:**
- Simple config → TOML string
- Complex nested structures
- Large documents
- Round-trip performance (parse → write)

**Current Gap:** No writer benchmarks exist yet.

### 5. Scale Testing (Lower Priority)

**Goal:** Identify performance limits.

**Tests:**
- Small (< 1KB): typical app configs
- Medium (1-10KB): build system configs
- Large (10-100KB): comprehensive settings
- Pathological (100KB+): stress test, identify bottlenecks

**Value:** Mostly academic - typical configs are < 10KB.

## Implementation Roadmap

### Phase 1: Python Comparison (Highest Value)
1. Create `compare_python.mojo` - runs mojo-toml benchmarks
2. Create `compare_python.py` - equivalent Python script using tomli
3. Create `run_comparison.sh` - runs both and reports speedup
4. Test with 5-10 real-world TOML files
5. Document results in `PERFORMANCE.md`

**Effort:** ~4-6 hours
**Impact:** High - directly answers "Is Mojo faster?"

### Phase 2: Writer Benchmarks
1. Create `benchmark_writer.mojo`
2. Test primitive types, arrays, tables
3. Measure round-trip performance
4. Compare write speed to Python's tomli_w (if available)

**Effort:** ~2-3 hours
**Impact:** Medium - completes v0.4.0 feature coverage

### Phase 3: Memory Profiling
1. Add memory tracking to benchmarks
2. Document allocation patterns
3. Compare with Python's memory overhead

**Effort:** ~3-4 hours
**Impact:** Medium - valuable for specific use cases

### Phase 4: Real-World Collection
1. Gather 20-30 real project TOML files
2. Create automated test suite
3. Report performance characteristics

**Effort:** ~2-3 hours
**Impact:** Low-medium - nice to have, not critical

## Open Questions

1. **User Expectations:** Do users care more about speed or memory?
2. **Typical File Sizes:** What's the 95th percentile TOML file size?
3. **Bottlenecks:** Where would SIMD actually help? (String scanning? Array parsing?)
4. **Comparison Target:** Compare to Python `tomli`, Rust `toml`, or both?

## Benchmarking Best Practices

**Do:**
- Use realistic TOML files (not synthetic)
- Warm up before measuring (JIT compilation)
- Run multiple iterations (reduce variance)
- Report median/mean/p95 (not just single runs)
- Document hardware (CPU, RAM)
- Compare apples-to-apples (same files, same operations)

**Don't:**
- Over-optimise for unrealistic cases (100KB+ configs)
- Cherry-pick favourable results
- Ignore Python startup overhead (include in measurements)
- Forget about memory usage
- Benchmark without validation (ensure correctness first)

## Success Criteria

For v0.6.0 release, we should be able to answer:

1. ✅ "How much faster is mojo-toml than Python's tomli?"
   - Target: 2-5x faster on typical configs
2. ✅ "Does it handle real-world TOML files efficiently?"
   - Target: < 5ms for typical project configs
3. ✅ "What about memory usage?"
   - Target: Comparable or better than Python
4. ✅ "How fast is the writer?"
   - Target: < 10ms for typical configs

## References

- Current benchmarks: `benchmarks/benchmark_parser.mojo`
- Performance docs: `docs/PERFORMANCE.md`
- Python tomli: https://github.com/hukkin/tomli
- TOML spec: https://toml.io/en/v1.0.0

## Notes

- Current performance (2ms for pixi.toml) is already excellent
- Focus on practical comparisons, not theoretical maximums
- SIMD optimisations likely unnecessary for typical use cases
- Comparative benchmarks have highest value for users
