"""Validation and error detection tests for mojo-toml.

Tests that the parser correctly validates TOML and raises appropriate errors.
"""

from testing import assert_equal, assert_true, TestSuite, assert_raises
from toml import parse


fn test_duplicate_key_error() raises:
    """Test that duplicate keys at root level raise an error."""
    with assert_raises(contains="Duplicate key"):
        var data = parse("""
name = "first"
name = "second"
""")


fn test_duplicate_key_in_table() raises:
    """Test that duplicate keys in table sections raise an error."""
    with assert_raises(contains="Duplicate key"):
        var data = parse("""
[section]
key = "first"
key = "second"
""")


fn test_duplicate_nested_key() raises:
    """Test that duplicate nested keys raise an error."""
    with assert_raises(contains="Duplicate key"):
        var data = parse("""
a.b.c = 1
a.b.c = 2
""")


fn test_duplicate_key_different_tables() raises:
    """Test that same key in different tables is allowed."""
    # This should NOT raise an error
    var data = parse("""
[section1]
key = "value1"

[section2]
key = "value2"
""")
    
    var section1 = data["section1"].as_table()
    var section2 = data["section2"].as_table()
    assert_equal(section1["key"].as_string(), "value1")
    assert_equal(section2["key"].as_string(), "value2")


fn test_redefining_table_as_value() raises:
    """Test that redefining a table as a value raises an error."""
    with assert_raises(contains="not a table"):
        var data = parse("""
[database]
host = "localhost"

[database.host]
port = 5432
""")


fn test_array_of_tables_not_supported() raises:
    """Test that array of tables syntax raises appropriate error."""
    with assert_raises(contains="Expected key in table header"):
        var data = parse("""
[[products]]
name = "Hammer"
sku = 738594937

[[products]]
name = "Nail"
sku = 284758393
""")


fn test_trailing_comma_in_inline_table() raises:
    """Test that trailing comma in inline table raises error."""
    with assert_raises(contains="Trailing comma"):
        var data = parse("""
server = {host = "localhost", port = 8080,}
""")


def main():
    """Run all validation tests."""
    var suite = TestSuite()
    suite.test[test_duplicate_key_error]()
    suite.test[test_duplicate_key_in_table]()
    suite.test[test_duplicate_nested_key]()
    suite.test[test_duplicate_key_different_tables]()
    suite.test[test_redefining_table_as_value]()
    suite.test[test_array_of_tables_not_supported]()
    suite.test[test_trailing_comma_in_inline_table]()
    suite^.run()
