"""Round-trip writer tests for mojo-toml.

Tests that parse → write → parse produces semantically equivalent results.
"""

from std.testing import assert_equal, assert_true, TestSuite
from toml import TomlValue, parse, to_toml
from std.collections import Dict, List


def compare_toml_values(left: TomlValue, right: TomlValue) raises -> Bool:
    """Compare two TomlValue instances for semantic equality.

    Returns True if values are semantically equal (same type and value).
    Note: Dict order may differ, so we compare contents not string representation.
    """
    # Check types match
    if left.is_string() and right.is_string():
        return left.as_string() == right.as_string()
    elif left.is_int() and right.is_int():
        return left.as_int() == right.as_int()
    elif left.is_float() and right.is_float():
        var lf = left.as_float()
        var rf = right.as_float()
        # Handle NaN specially (NaN != NaN)
        if lf != lf and rf != rf:
            return True
        return lf == rf
    elif left.is_bool() and right.is_bool():
        return left.as_bool() == right.as_bool()
    elif left.is_array() and right.is_array():
        var larr = left.as_array()
        var rarr = right.as_array()
        if len(larr) != len(rarr):
            return False
        for i in range(len(larr)):
            if not compare_toml_values(larr[i], rarr[i]):
                return False
        return True
    elif left.is_table() and right.is_table():
        var ltable = left.as_table()
        var rtable = right.as_table()
        if len(ltable) != len(rtable):
            return False
        # Check all keys in left exist in right with same values
        for entry in ltable.items():
            if not rtable.__contains__(entry.key):
                return False
            if not compare_toml_values(entry.value, rtable[entry.key]):
                return False
        return True
    else:
        # Type mismatch
        return False


def compare_toml_dicts(left: Dict[String, TomlValue], right: Dict[String, TomlValue]) raises -> Bool:
    """Compare two TOML dictionaries for semantic equality."""
    if len(left) != len(right):
        return False

    for entry in left.items():
        if not right.__contains__(entry.key):
            return False
        if not compare_toml_values(entry.value, right[entry.key]):
            return False

    return True


def test_roundtrip_simple() raises:
    """Test round-trip with simple key-value pairs."""
    var original_toml = """
name = "test-app"
version = "1.0.0"
port = 8080
debug = false
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_with_arrays() raises:
    """Test round-trip with arrays."""
    var original_toml = """
numbers = [1, 2, 3, 4, 5]
colors = ["red", "green", "blue"]
mixed = [1, "two", 3.0, true]
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_with_table() raises:
    """Test round-trip with a simple table."""
    var original_toml = """
title = "My App"

[database]
host = "localhost"
port = 5432
user = "admin"
enabled = true
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_nested_tables() raises:
    """Test round-trip with nested tables."""
    var original_toml = """
[database.primary]
host = "primary.example.com"
port = 5432

[database.replica]
host = "replica.example.com"
port = 5433
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_special_floats() raises:
    """Test round-trip with special float values."""
    var original_toml = """
pos_infinity = inf
neg_infinity = -inf
not_a_number = nan
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_string_escapes() raises:
    """Test round-trip with escaped strings."""
    # Simple newline escape test
    var original_toml = 'message = "Hello\\nWorld"'

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_nested_arrays() raises:
    """Test round-trip with nested arrays."""
    var original_toml = """
matrix = [[1, 2], [3, 4], [5, 6]]
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_complex_structure() raises:
    """Test round-trip with complex nested structure."""
    var original_toml = """
title = "Complex App"
version = "2.0.0"

[app]
name = "myapp"
debug = false
port = 8080

[database.primary]
host = "primary.db"
port = 5432
timeout = 30.5

[database.replica]
host = "replica.db"
port = 5433
timeout = 45.0
"""

    var parsed1 = parse(original_toml)
    var written = to_toml(parsed1)
    var parsed2 = parse(written)

    assert_true(compare_toml_dicts(parsed1, parsed2))


def test_roundtrip_root_tables() raises:
    """Test round-trip with root-level tables."""
    var config = Dict[String, TomlValue]()

    # Create tables that will be written as [sections]
    var point1 = Dict[String, TomlValue]()
    point1["x"] = TomlValue(10)
    point1["y"] = TomlValue(20)

    var point2 = Dict[String, TomlValue]()
    point2["x"] = TomlValue(30)
    point2["y"] = TomlValue(40)

    config["point1"] = TomlValue(point1^)
    config["point2"] = TomlValue(point2^)

    var written = to_toml(config)
    var parsed = parse(written)

    assert_true(compare_toml_dicts(config, parsed))


def test_roundtrip_pixi_toml() raises:
    """Test round-trip with the project's own pixi.toml file."""
    # Read pixi.toml
    var content: String
    with open("pixi.toml", "r") as f:
        content = f.read()

    # Parse it
    var parsed1 = parse(content)

    # Write it back
    var written = to_toml(parsed1)

    # Parse the written version
    var parsed2 = parse(written)

    # Compare semantic equality
    assert_true(compare_toml_dicts(parsed1, parsed2))

    # Verify key sections exist (Pixi schema may use [workspace] or [project])
    assert_true(parsed2.__contains__("workspace") or parsed2.__contains__("project"))
    assert_true(parsed2.__contains__("tasks"))
    assert_true(parsed2.__contains__("dependencies"))


def main() raises:
    """Run all round-trip tests."""
    var suite = TestSuite()
    suite.test[test_roundtrip_simple]()
    suite.test[test_roundtrip_with_arrays]()
    suite.test[test_roundtrip_with_table]()
    suite.test[test_roundtrip_nested_tables]()
    suite.test[test_roundtrip_special_floats]()
    suite.test[test_roundtrip_string_escapes]()
    suite.test[test_roundtrip_nested_arrays]()
    suite.test[test_roundtrip_complex_structure]()
    suite.test[test_roundtrip_root_tables]()
    suite.test[test_roundtrip_pixi_toml]()
    suite^.run()
