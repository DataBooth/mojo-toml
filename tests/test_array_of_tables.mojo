"""Tests for array of tables (TOML 1.0 [[section]] syntax).

Tests the [[section]] array-of-tables feature which allows defining
arrays of tables in TOML configuration files.
"""

from testing import assert_equal, assert_true, TestSuite
from toml import parse


fn test_simple_array_of_tables() raises:
    """Test basic array of tables syntax."""
    var toml = """
[[products]]
name = "Hammer"
sku = 738594937

[[products]]
name = "Nail"
sku = 284758393
"""
    var data = parse(toml)
    var products = data["products"].as_array()

    assert_equal(len(products), 2)
    assert_equal(products[0].as_table()["name"].as_string(), "Hammer")
    assert_equal(products[0].as_table()["sku"].as_int(), 738594937)
    assert_equal(products[1].as_table()["name"].as_string(), "Nail")
    assert_equal(products[1].as_table()["sku"].as_int(), 284758393)


fn test_empty_array_of_tables() raises:
    """Test array of tables with no keys."""
    var toml = """
[[empty]]

[[empty]]
"""
    var data = parse(toml)
    var empty = data["empty"].as_array()

    assert_equal(len(empty), 2)
    # Each should be an empty table
    assert_equal(len(empty[0].as_table()), 0)
    assert_equal(len(empty[1].as_table()), 0)


fn test_single_array_element() raises:
    """Test array of tables with single element."""
    var toml = """
[[items]]
value = 42
"""
    var data = parse(toml)
    var items = data["items"].as_array()

    assert_equal(len(items), 1)
    assert_equal(items[0].as_table()["value"].as_int(), 42)


fn test_nested_array_of_tables() raises:
    """Test nested array of tables: [[fruit.variety]]."""
    var toml = """
[[fruit]]
name = "apple"

  [[fruit.variety]]
  name = "red delicious"

  [[fruit.variety]]
  name = "granny smith"

[[fruit]]
name = "banana"

  [[fruit.variety]]
  name = "plantain"
"""
    var data = parse(toml)
    var fruit = data["fruit"].as_array()

    assert_equal(len(fruit), 2)

    # First fruit
    assert_equal(fruit[0].as_table()["name"].as_string(), "apple")
    var apple_varieties = fruit[0].as_table()["variety"].as_array()
    assert_equal(len(apple_varieties), 2)
    assert_equal(apple_varieties[0].as_table()["name"].as_string(), "red delicious")
    assert_equal(apple_varieties[1].as_table()["name"].as_string(), "granny smith")

    # Second fruit
    assert_equal(fruit[1].as_table()["name"].as_string(), "banana")
    var banana_varieties = fruit[1].as_table()["variety"].as_array()
    assert_equal(len(banana_varieties), 1)
    assert_equal(banana_varieties[0].as_table()["name"].as_string(), "plantain")


fn test_mixed_tables_and_arrays() raises:
    """Test document with both regular tables and array-of-tables."""
    var toml = """
[database]
host = "localhost"

[[servers]]
name = "alpha"
ip = "10.0.0.1"

[[servers]]
name = "beta"
ip = "10.0.0.2"

[cache]
ttl = 300
"""
    var data = parse(toml)

    # Regular table
    var db = data["database"].as_table()
    assert_equal(db["host"].as_string(), "localhost")

    # Array of tables
    var servers = data["servers"].as_array()
    assert_equal(len(servers), 2)
    assert_equal(servers[0].as_table()["name"].as_string(), "alpha")
    assert_equal(servers[1].as_table()["name"].as_string(), "beta")

    # Another regular table
    var cache = data["cache"].as_table()
    assert_equal(cache["ttl"].as_int(), 300)


fn test_dotted_keys_in_array_of_tables() raises:
    """Test dotted keys within array-of-tables entries."""
    var toml = """
[[configs]]
server.host = "localhost"
server.port = 8080
"""
    var data = parse(toml)
    var configs = data["configs"].as_array()

    assert_equal(len(configs), 1)
    var server = configs[0].as_table()["server"].as_table()
    assert_equal(server["host"].as_string(), "localhost")
    assert_equal(server["port"].as_int(), 8080)


fn test_array_values_in_array_of_tables() raises:
    """Test arrays as values within array-of-tables."""
    var toml = """
[[packages]]
name = "foo"
tags = ["web", "api"]

[[packages]]
name = "bar"
tags = ["cli"]
"""
    var data = parse(toml)
    var packages = data["packages"].as_array()

    assert_equal(len(packages), 2)
    var foo_tags = packages[0].as_table()["tags"].as_array()
    assert_equal(len(foo_tags), 2)
    assert_equal(foo_tags[0].as_string(), "web")

    var bar_tags = packages[1].as_table()["tags"].as_array()
    assert_equal(len(bar_tags), 1)
    assert_equal(bar_tags[0].as_string(), "cli")


fn test_inline_table_in_array_of_tables() raises:
    """Test inline tables within array-of-tables."""
    var toml = """
[[entries]]
id = 1
metadata = { author = "Alice", tags = ["foo"] }

[[entries]]
id = 2
metadata = { author = "Bob", tags = ["bar"] }
"""
    var data = parse(toml)
    var entries = data["entries"].as_array()

    assert_equal(len(entries), 2)
    var metadata1 = entries[0].as_table()["metadata"].as_table()
    assert_equal(metadata1["author"].as_string(), "Alice")


fn test_multiple_array_of_tables_sections() raises:
    """Test multiple independent array-of-tables in same document."""
    var toml = """
[[users]]
name = "Alice"

[[users]]
name = "Bob"

[[groups]]
name = "admins"

[[groups]]
name = "users"
"""
    var data = parse(toml)

    var users = data["users"].as_array()
    assert_equal(len(users), 2)
    assert_equal(users[0].as_table()["name"].as_string(), "Alice")

    var groups = data["groups"].as_array()
    assert_equal(len(groups), 2)
    assert_equal(groups[0].as_table()["name"].as_string(), "admins")


# Error cases - these should raise errors


fn test_error_redefine_array_as_table() raises:
    """Test error: cannot redefine array-of-tables as regular table."""
    var toml = """
[[products]]
name = "Hammer"

[products]
type = "tools"
"""
    try:
        _ = parse(toml)
        raise Error("Should have raised error for redefining array as table")
    except:
        # Expected error
        pass


fn test_error_redefine_table_as_array() raises:
    """Test error: cannot redefine regular table as array-of-tables."""
    var toml = """
[database]
host = "localhost"

[[database]]
port = 5432
"""
    try:
        _ = parse(toml)
        raise Error("Should have raised error for redefining table as array")
    except:
        # Expected error
        pass


fn test_error_duplicate_keys_in_array_element() raises:
    """Test error: duplicate keys within same array element."""
    var toml = """
[[items]]
name = "first"
name = "second"
"""
    try:
        _ = parse(toml)
        raise Error("Should have raised error for duplicate keys")
    except:
        # Expected error
        pass


def main() raises:
    """Run all array-of-tables tests."""
    var suite = TestSuite()

    # Basic tests
    suite.test[test_simple_array_of_tables]()
    suite.test[test_empty_array_of_tables]()
    suite.test[test_single_array_element]()

    # Nesting and complexity
    suite.test[test_nested_array_of_tables]()
    suite.test[test_mixed_tables_and_arrays]()
    suite.test[test_dotted_keys_in_array_of_tables]()
    suite.test[test_array_values_in_array_of_tables]()
    suite.test[test_inline_table_in_array_of_tables]()
    suite.test[test_multiple_array_of_tables_sections]()

    # Error cases
    suite.test[test_error_redefine_array_as_table]()
    suite.test[test_error_redefine_table_as_array]()
    suite.test[test_error_duplicate_keys_in_array_element]()

    suite^.run()
