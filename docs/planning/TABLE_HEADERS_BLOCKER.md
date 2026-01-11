# Table Headers Implementation - SOLVED! 🎉

## Current Status

Table headers `[section]` are **fully implemented** with proper nested Dict structures!

This document is preserved for historical reference, showing the problem we initially encountered and how community feedback led to the solution.

### What Works ✅
- Flat key-value pairs: `name = "value"`
- Arrays: `numbers = [1, 2, 3]`
- Nested arrays: `matrix = [[1, 2], [3, 4]]`
- Inline tables: `point = {x = 1, y = 2}`
- Nested inline tables: `config = {server = {host = "localhost"}}`

### What Doesn't Work ❌
- Table headers: `[database]`
- Nested table headers: `[database.primary]`
- Files like pixi.toml, Cargo.toml, pyproject.toml that use table headers

## The Technical Problem

### Goal
Parse TOML with table headers and create nested Dict structure:

```toml
[database]
host = "localhost"
port = 5432

[server]
host = "0.0.0.0"
port = 8080
```

Should produce:
```python
{
  "database": {
    "host": "localhost",
    "port": 5432
  },
  "server": {
    "host": "0.0.0.0", 
    "port": 8080
  }
}
```

### The Blocker: Dict Iterator Limitations

Mojo's current Dict iterator returns `DictEntry` objects that cannot be subscripted:

```mojo
var dict = Dict[String, TomlValue]()
# ... populate dict ...

# ❌ This doesn't work:
for entry in dict.items():
    var key = entry[].key     # Error: DictEntry is not subscriptable
    var val = entry[].value   # Error: DictEntry is not subscriptable
```

Error message:
```
'_DictEntryIter[String, TomlValue, default_hasher, ...].Element' is not subscriptable,
it does not implement the `__getitem__`/`__setitem__` methods
```

### What We Need

To build nested dictionaries, we need to:
1. **Navigate** to a nested table (e.g., `result["database"]["primary"]`)
2. **Modify** that nested table by adding keys
3. **Update** the parent dict with the modified child

All three operations require iterating over Dict entries to copy/merge structures, which hits the `DictEntry` subscripting issue.

### Approaches Attempted

1. **Direct Nested Mutation** 
   - Problem: Can't maintain mutable reference to nested Dict
   - Mojo returns copies, not references

2. **Get-Modify-Put Pattern**
   ```mojo
   var subtable = root["key"].as_table()  # Gets a copy
   subtable["newkey"] = value             # Modifies the copy
   root["key"] = TomlValue(subtable^)     # Put back
   ```
   - Problem: Requires iterating Dict to copy, hits subscript issue

3. **Flat Storage with Post-Processing**
   - Store as flat keys: `"database.host"`, `"database.port"`
   - Convert to nested structure afterwards
   - Problem: Still requires Dict iteration to build nested structure

4. **Recursive Path Navigation**
   - Navigate path step-by-step, creating missing tables
   - Problem: Requires Dict iteration to check existence and copy

All approaches hit the same wall: **cannot access Dict entries during iteration**.

## Impact

### Files That Won't Parse
- ✗ pixi.toml (package manager config)
- ✗ Cargo.toml (Rust package manager)
- ✗ pyproject.toml (Python project metadata)
- ✗ mojoproject.toml (Mojo project config)
- ✗ Most real-world TOML files

### Files That Will Parse
- ✓ Simple config files with only flat keys
- ✓ Config files using only inline tables
- ✓ TOML with arrays but no table headers

## Potential Solutions Analysis

### Option 1: Wait for Mojo Language Improvements ⏳
**What:** Wait for Mojo to fix Dict iterator subscripting

**Pros:**
- No workaround needed
- Clean, idiomatic solution
- Mojo is evolving rapidly

**Cons:**
- Unknown timeline (could be weeks or months)
- Blocks project progress
- No guarantee of fix priority

**Verdict:** Not viable if you need table headers soon

---

### Option 2: Custom Hash Map Implementation 🛠️
**What:** Implement our own hash map that supports proper iteration

**Pros:**
- Full control over iteration behaviour
- Can design for our exact needs
- Educational

**Cons:**
- **High complexity** (hundreds of lines of code)
- Performance likely worse than stdlib Dict
- Memory management challenges in Mojo
- Reinventing the wheel
- Long implementation time

**Verdict:** Overkill for this use case

---

### Option 3: Flat Key Storage (Dotted Keys) 🔑
**What:** Store everything with flat dotted keys internally

```mojo
// Instead of: {"database": {"host": "localhost"}}
// Store as: {"database.host": "localhost"}
```

**Pros:**
- **Simple to implement** (already mostly done)
- Avoids all Dict iteration issues
- Still fully functional - users can access via dotted keys
- Common pattern (used by some config libraries)

**Cons:**
- Not "true" nested structure
- User API less intuitive: `config["database.host"]` vs `config["database"]["host"]`
- Doesn't match expected TOML semantics

**Verdict:** **Most pragmatic short-term solution**

---

### Option 4: Array-Based Storage 📊
**What:** Use List[(String, TomlValue)] instead of Dict

**Pros:**
- List iteration works perfectly in Mojo
- Can iterate and manipulate easily
- Maintains insertion order naturally

**Cons:**
- O(n) lookup instead of O(1)
- Wastes memory for duplicate path segments
- Still need to build nested structure somehow
- API becomes `get_key("database")` instead of `config["database"]`

**Verdict:** Trades one problem for another

---

### Option 5: External C/C++ Library via FFI 🔗
**What:** Wrap existing C/C++ TOML parser (toml++ or toml11)

**Pros:**
- Battle-tested, fully compliant parser
- All features work immediately
- Good performance

**Cons:**
- **Defeats the purpose** ("first native Mojo parser")
- FFI complexity
- External dependency
- Not educational/learning value lost

**Verdict:** Against project goals

---

### Option 6: Python Interop Helper 🐍
**What:** Use Mojo's Python interop to call Python's `tomli` for parsing, convert result

**Pros:**
- Quick to implement
- Leverages existing, compliant parser
- Mojo already has Python interop

**Cons:**
- Requires Python runtime
- **Defeats the "zero Python dependencies" goal**
- Not a native solution
- Performance overhead

**Verdict:** Against project goals

---

## Recommended Approach

### **Hybrid Solution: Flat Keys Now + Proper Nesting Later**

1. **Phase 1 (Now):** Implement flat dotted key storage
   - Users access via: `config["database.host"]`
   - Document this clearly
   - Mark as "beta" / "table headers in progress"
   - **Estimated time:** 1-2 hours

2. **Phase 2 (Later):** Add helper methods for nested access
   ```mojo
   fn get_nested(path: List[String]) -> TomlValue
   fn get_table(name: String) -> Dict[String, TomlValue]
   ```
   - **Estimated time:** 2-3 hours

3. **Phase 3 (When Mojo improves):** Migrate to proper nested Dict
   - Keep flat-key API for backward compatibility
   - Add nested Dict API
   - **Estimated time:** 3-4 hours

### Why This Works

- ✅ **Unblocks development** - can parse pixi.toml TODAY
- ✅ **Users get value** - functional parser for real files
- ✅ **Honest** - clearly document current limitations
- ✅ **Forward compatible** - can improve later without breaking changes
- ✅ **Learning continues** - still a native Mojo parser

### Acceptance Criteria for Phase 1

- [ ] Parse `[section]` headers successfully
- [ ] Store as flat keys: `"section.key"`
- [ ] Parse pixi.toml without errors
- [ ] Can access values: `data["workspace.name"]`
- [ ] Document flat-key access pattern
- [ ] Update README with current limitations
- [ ] 8 table tests pass
- [ ] All 71 existing tests still pass

---

## 🎉 THE SOLUTION - Community Feedback (2026-01-07)

### What Changed

Posted the blocker analysis to Modular Discord #mojo channel asking for guidance. Received immediate feedback:

> **Community Response:** "I think you don't need to de-reference dict items anymore. Just omit the []"

### The Fix

Mojo's Dict iterator DOES work - we just don't need the `[]` subscript operator!

```mojo
# ✅ WORKS - What we should have tried first!
for entry in dict.items():
    var key = entry.key      # Direct access!
    var value = entry.value  # No [] needed!

# ❌ DOESN'T WORK - What we were trying
for entry in dict.items():
    var key = entry[].key    # DictEntry is not subscriptable
    var value = entry[].value
```

### Implementation

With proper Dict iteration, we implemented:

1. **Nested Dict Copying in `TomlValue.copy()`:**
   ```mojo
   var table_copy = Dict[String, TomlValue]()
   for entry in self.table_value.items():
       table_copy[entry.key] = entry.value.copy()
   return TomlValue(table_copy^)
   ```

2. **Recursive Table Path Creation:**
   - `ensure_table_path()` - Creates nested table structure
   - `set_in_table_path()` - Sets values at any depth
   - Pure functional approach (return new Dicts)

3. **Proper Nested Access:**
   ```mojo
   var db = config["database"].as_table()
   var host = db["host"].as_string()
   ```

### Results

- ✅ All 79 tests pass with nested structures
- ✅ pixi.toml parses correctly  
- ✅ Deep nesting works (e.g., `[a.b.c.d]`)
- ✅ No flat keys needed!
- ✅ Proper TOML semantics

### Lessons Learned

1. **Ask the community early** - They know the language better
2. **Test simple cases first** - We assumed `[]` was needed without testing
3. **Mojo is evolving** - Features improve, documentation may lag
4. **Document discoveries** - This file now helps others

### Files Changed

- `src/toml/parser.mojo` - Fixed Dict iteration, added nested helpers
- `tests/test_tables.mojo` - Updated for nested access
- `examples/parse_pixi.mojo` - Demonstrates nested tables
- All 79 tests updated and passing

### v0.2.0 Release

Skipped v0.1.0-alpha entirely and jumped straight to v0.2.0 with proper nested tables!

---

*Problem identified: 2026-01-07*  
*Solution found: 2026-01-07 (same day!)*  
*Thanks to: Modular Discord community*
