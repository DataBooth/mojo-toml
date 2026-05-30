"""Tests for dotted keys in mojo-toml.

Tests the dotted key syntax (a.b.c = value) which creates nested table structures.
"""

from testing import assert_equal, assert_true, TestSuite, assert_raises
from toml import parse


fn test_simple_dotted_key() raises:
    """Test simple dotted key creates nested table."""
    var data = parse("""
a.b = "value"
""")

    assert_true(data["a"].is_table())
    var a_table = data["a"].as_table()
    assert_equal(a_table["b"].as_string(), "value")


fn test_multiple_dotted_keys() raises:
    """Test multiple dotted keys in same namespace."""
    var data = parse("""
a.b = "value1"
a.c = "value2"
""")

    var a_table = data["a"].as_table()
    assert_equal(a_table["b"].as_string(), "value1")
    assert_equal(a_table["c"].as_string(), "value2")


fn test_deeply_dotted_key() raises:
    """Test deeply nested dotted key."""
    var data = parse("""
a.b.c.d.e = 42
""")

    var a = data["a"].as_table()
    var b = a["b"].as_table()
    var c = b["c"].as_table()
    var d = c["d"].as_table()
    assert_equal(d["e"].as_int(), 42)


fn test_dotted_key_with_table_header() raises:
    """Test dotted key combined with table header."""
    var data = parse("""
[section]
a.b = "nested"
c = "flat"
""")

    var section = data["section"].as_table()
    assert_equal(section["c"].as_string(), "flat")

    var a = section["a"].as_table()
    assert_equal(a["b"].as_string(), "nested")


fn test_dotted_key_mixed_values() raises:
    """Test dotted keys with different value types."""
    var data = parse("""
server.host = "localhost"
server.port = 8080
server.enabled = true
""")

    var server = data["server"].as_table()
    assert_equal(server["host"].as_string(), "localhost")
    assert_equal(server["port"].as_int(), 8080)
    assert_equal(server["enabled"].as_bool(), True)


fn test_dotted_key_with_inline_table() raises:
    """Test dotted key with inline table value."""
    var data = parse("""
a.b = {c = "value"}
""")

    var a = data["a"].as_table()
    var b = a["b"].as_table()
    assert_equal(b["c"].as_string(), "value")


fn test_dotted_key_array() raises:
    """Test dotted key with array value."""
    var data = parse("""
a.b = [1, 2, 3]
""")

    var a = data["a"].as_table()
    var arr = a["b"].as_array()
    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_int(), 1)


def main() raises:
    """Run all dotted key tests."""
    var suite = TestSuite()
    suite.test[test_simple_dotted_key]()
    suite.test[test_multiple_dotted_keys]()
    suite.test[test_deeply_dotted_key]()
    suite.test[test_dotted_key_with_table_header]()
    suite.test[test_dotted_key_mixed_values]()
    suite.test[test_dotted_key_with_inline_table]()
    suite.test[test_dotted_key_array]()
    suite^.run()
