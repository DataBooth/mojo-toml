"""Inline table tests for mojo-toml.

Tests TOML inline table parsing including simple tables, nested tables,
tables with various value types, and tables within arrays.
"""

from testing import assert_equal, assert_true, assert_false, TestSuite
from toml import parse


fn test_empty_inline_table() raises:
    """Test parsing empty inline table."""
    var data = parse("empty = {}")
    
    assert_true(data.__contains__("empty"))
    assert_true(data["empty"].is_table())
    
    var table = data["empty"].as_table()
    assert_equal(len(table), 0)


fn test_simple_inline_table() raises:
    """Test parsing simple inline table."""
    var data = parse('point = {x = 1, y = 2}')
    
    assert_true(data["point"].is_table())
    var table = data["point"].as_table()
    
    assert_equal(len(table), 2)
    assert_true(table.__contains__("x"))
    assert_true(table.__contains__("y"))
    assert_equal(table["x"].as_int(), 1)
    assert_equal(table["y"].as_int(), 2)


fn test_inline_table_strings() raises:
    """Test inline table with string values."""
    var data = parse('person = {name = "Alice", role = "Engineer"}')
    
    assert_true(data["person"].is_table())
    var table = data["person"].as_table()
    
    assert_equal(len(table), 2)
    assert_equal(table["name"].as_string(), "Alice")
    assert_equal(table["role"].as_string(), "Engineer")


fn test_inline_table_mixed_types() raises:
    """Test inline table with mixed value types."""
    var data = parse('config = {port = 8080, host = "localhost", debug = true, timeout = 30.5}')
    
    assert_true(data["config"].is_table())
    var table = data["config"].as_table()
    
    assert_equal(len(table), 4)
    assert_equal(table["port"].as_int(), 8080)
    assert_equal(table["host"].as_string(), "localhost")
    assert_true(table["debug"].as_bool())
    assert_equal(table["timeout"].as_float(), 30.5)


fn test_inline_table_with_array() raises:
    """Test inline table containing an array."""
    var data = parse('data = {values = [1, 2, 3], name = "test"}')
    
    assert_true(data["data"].is_table())
    var table = data["data"].as_table()
    
    assert_equal(len(table), 2)
    assert_true(table["values"].is_array())
    
    var arr = table["values"].as_array()
    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_int(), 2)
    assert_equal(arr[2].as_int(), 3)
    
    assert_equal(table["name"].as_string(), "test")


fn test_nested_inline_table() raises:
    """Test inline table containing another inline table."""
    var data = parse('server = {address = {host = "localhost", port = 8080}, name = "main"}')
    
    assert_true(data["server"].is_table())
    var server = data["server"].as_table()
    
    assert_equal(len(server), 2)
    assert_equal(server["name"].as_string(), "main")
    
    assert_true(server["address"].is_table())
    var address = server["address"].as_table()
    
    assert_equal(len(address), 2)
    assert_equal(address["host"].as_string(), "localhost")
    assert_equal(address["port"].as_int(), 8080)


fn test_array_of_inline_tables() raises:
    """Test array containing inline tables."""
    var data = parse('users = [{name = "Alice", age = 30}, {name = "Bob", age = 25}]')
    
    assert_true(data["users"].is_array())
    var users = data["users"].as_array()
    
    assert_equal(len(users), 2)
    
    # First user
    assert_true(users[0].is_table())
    var user1 = users[0].as_table()
    assert_equal(user1["name"].as_string(), "Alice")
    assert_equal(user1["age"].as_int(), 30)
    
    # Second user
    assert_true(users[1].is_table())
    var user2 = users[1].as_table()
    assert_equal(user2["name"].as_string(), "Bob")
    assert_equal(user2["age"].as_int(), 25)


fn test_inline_table_single_pair() raises:
    """Test inline table with single key-value pair."""
    var data = parse('singleton = {key = "value"}')
    
    assert_true(data["singleton"].is_table())
    var table = data["singleton"].as_table()
    
    assert_equal(len(table), 1)
    assert_equal(table["key"].as_string(), "value")


fn test_inline_table_with_spaces() raises:
    """Test inline table with extra spacing."""
    var data = parse('spaced = {  a = 1  ,  b = 2  }')
    
    assert_true(data["spaced"].is_table())
    var table = data["spaced"].as_table()
    
    assert_equal(len(table), 2)
    assert_equal(table["a"].as_int(), 1)
    assert_equal(table["b"].as_int(), 2)


fn test_multiple_inline_tables() raises:
    """Test parsing multiple inline tables."""
    var data = parse("""
point1 = {x = 1, y = 2}
point2 = {x = 3, y = 4}
point3 = {x = 5, y = 6}
""")
    
    assert_true(data["point1"].is_table())
    assert_true(data["point2"].is_table())
    assert_true(data["point3"].is_table())
    
    var p1 = data["point1"].as_table()
    assert_equal(p1["x"].as_int(), 1)
    assert_equal(p1["y"].as_int(), 2)
    
    var p2 = data["point2"].as_table()
    assert_equal(p2["x"].as_int(), 3)
    assert_equal(p2["y"].as_int(), 4)
    
    var p3 = data["point3"].as_table()
    assert_equal(p3["x"].as_int(), 5)
    assert_equal(p3["y"].as_int(), 6)


fn test_inline_table_with_quoted_keys() raises:
    """Test inline table with quoted keys."""
    var data = parse('data = {"127.0.0.1" = "localhost", "special-key" = "value"}')
    
    assert_true(data["data"].is_table())
    var table = data["data"].as_table()
    
    assert_equal(len(table), 2)
    assert_equal(table["127.0.0.1"].as_string(), "localhost")
    assert_equal(table["special-key"].as_string(), "value")


fn test_inline_table_booleans() raises:
    """Test inline table with boolean values."""
    var data = parse('flags = {enabled = true, debug = false, verbose = true}')
    
    assert_true(data["flags"].is_table())
    var table = data["flags"].as_table()
    
    assert_equal(len(table), 3)
    assert_true(table["enabled"].as_bool())
    assert_false(table["debug"].as_bool())
    assert_true(table["verbose"].as_bool())


fn test_deeply_nested_inline_table() raises:
    """Test deeply nested inline tables."""
    var data = parse('root = {a = {b = {c = {value = 42}}}}')
    
    assert_true(data["root"].is_table())
    var root = data["root"].as_table()
    
    assert_true(root["a"].is_table())
    var a = root["a"].as_table()
    
    assert_true(a["b"].is_table())
    var b = a["b"].as_table()
    
    assert_true(b["c"].is_table())
    var c = b["c"].as_table()
    
    assert_equal(c["value"].as_int(), 42)


def main():
    """Run all inline table tests."""
    var suite = TestSuite()
    suite.test[test_empty_inline_table]()
    suite.test[test_simple_inline_table]()
    suite.test[test_inline_table_strings]()
    suite.test[test_inline_table_mixed_types]()
    suite.test[test_inline_table_with_array]()
    suite.test[test_nested_inline_table]()
    suite.test[test_array_of_inline_tables]()
    suite.test[test_inline_table_single_pair]()
    suite.test[test_inline_table_with_spaces]()
    suite.test[test_multiple_inline_tables]()
    suite.test[test_inline_table_with_quoted_keys]()
    suite.test[test_inline_table_booleans]()
    suite.test[test_deeply_nested_inline_table]()
    suite^.run()
