"""Parser tests for mojo-toml.

Tests the conversion of tokens into structured data.
"""

from testing import assert_equal, assert_true, TestSuite
from toml import parse, TomlValue


fn test_parse_string_value() raises:
    """Test parsing simple string value."""
    var data = parse('name = "mojo-toml"')

    assert_true(data.__contains__("name"))
    assert_true(data["name"].is_string())
    assert_equal(data["name"].as_string(), "mojo-toml")


fn test_parse_integer_value() raises:
    """Test parsing integer value."""
    var data = parse("port = 8080")

    assert_true(data.__contains__("port"))
    assert_true(data["port"].is_int())
    assert_equal(data["port"].as_int(), 8080)


fn test_parse_float_value() raises:
    """Test parsing float value."""
    var data = parse("pi = 3.14159")

    assert_true(data.__contains__("pi"))
    assert_true(data["pi"].is_float())
    # Compare floats with small tolerance
    var diff = data["pi"].as_float() - 3.14159
    assert_true(diff < 0.00001 and diff > -0.00001)


fn test_parse_boolean_values() raises:
    """Test parsing boolean values."""
    var data = parse("enabled = true\ndisabled = false")

    assert_true(data.__contains__("enabled"))
    assert_true(data["enabled"].is_bool())
    assert_true(data["enabled"].as_bool())

    assert_true(data.__contains__("disabled"))
    assert_true(data["disabled"].is_bool())
    assert_true(not data["disabled"].as_bool())


fn test_parse_multiple_keys() raises:
    """Test parsing multiple key-value pairs."""
    var data = parse('name = "test"\nversion = "0.1.0"\nport = 8080')

    assert_true(data.__contains__("name"))
    assert_true(data.__contains__("version"))
    assert_true(data.__contains__("port"))

    assert_equal(data["name"].as_string(), "test")
    assert_equal(data["version"].as_string(), "0.1.0")
    assert_equal(data["port"].as_int(), 8080)


fn test_parse_with_comments() raises:
    """Test parsing with comments."""
    var data = parse('# This is a comment\nname = "value"  # inline comment')

    assert_true(data.__contains__("name"))
    assert_equal(data["name"].as_string(), "value")


fn test_parse_empty_string() raises:
    """Test parsing empty string value."""
    var data = parse('empty = ""')

    assert_true(data.__contains__("empty"))
    assert_equal(data["empty"].as_string(), "")


fn test_parse_negative_numbers() raises:
    """Test parsing negative numbers."""
    var data = parse("negative_int = -42\nnegative_float = -3.14")

    assert_true(data.__contains__("negative_int"))
    assert_equal(data["negative_int"].as_int(), -42)

    assert_true(data.__contains__("negative_float"))
    var val = data["negative_float"].as_float()
    assert_true(val < -3.13 and val > -3.15)


fn test_parse_special_floats() raises:
    """Test parsing special float values (inf, nan)."""
    var data = parse("infinity = inf\nnot_a_number = nan")

    assert_true(data.__contains__("infinity"))
    assert_true(data["infinity"].is_float())
    # inf == inf should be true
    var inf_val = data["infinity"].as_float()
    assert_true(inf_val == inf_val)

    assert_true(data.__contains__("not_a_number"))
    assert_true(data["not_a_number"].is_float())
    # nan != nan (standard floating point behavior)


fn test_parse_quoted_keys() raises:
    """Test parsing with quoted keys."""
    var data = parse('"127.0.0.1" = "localhost"')

    assert_true(data.__contains__("127.0.0.1"))
    assert_equal(data["127.0.0.1"].as_string(), "localhost")


def main() raises:
    """Run all parser tests."""
    var suite = TestSuite()
    suite.test[test_parse_string_value]()
    suite.test[test_parse_integer_value]()
    suite.test[test_parse_float_value]()
    suite.test[test_parse_boolean_values]()
    suite.test[test_parse_multiple_keys]()
    suite.test[test_parse_with_comments]()
    suite.test[test_parse_empty_string]()
    suite.test[test_parse_negative_numbers]()
    suite.test[test_parse_special_floats]()
    suite.test[test_parse_quoted_keys]()
    suite^.run()
