"""Basic writer tests for mojo-toml.

Tests the serialisation of primitive types, strings, arrays, and simple structures.
"""

from testing import assert_equal, assert_true, TestSuite
from toml import TomlValue, to_toml
from std.collections import Dict, List


fn test_write_string() raises:
    """Test writing a simple string value."""
    var config = Dict[String, TomlValue]()
    config["name"] = TomlValue("mojo-toml")

    var output = to_toml(config)
    assert_equal(output, "name = \"mojo-toml\"\n")


fn test_write_string_with_escapes() raises:
    """Test writing strings with special characters that need escaping."""
    var config = Dict[String, TomlValue]()
    config["message"] = TomlValue("Hello\nWorld")

    var output = to_toml(config)
    assert_equal(output, "message = \"Hello\\nWorld\"\n")


fn test_write_string_with_quotes() raises:
    """Test writing strings containing quotes."""
    var config = Dict[String, TomlValue]()
    config["quote"] = TomlValue("He said \"hello\"")

    var output = to_toml(config)
    assert_equal(output, "quote = \"He said \\\"hello\\\"\"\n")


fn test_write_string_with_backslash() raises:
    """Test writing strings containing backslashes."""
    var config = Dict[String, TomlValue]()
    config["path"] = TomlValue("C:\\Users\\test")

    var output = to_toml(config)
    assert_equal(output, "path = \"C:\\\\Users\\\\test\"\n")


fn test_write_integer() raises:
    """Test writing integer values."""
    var config = Dict[String, TomlValue]()
    config["port"] = TomlValue(8080)

    var output = to_toml(config)
    assert_equal(output, "port = 8080\n")


fn test_write_negative_integer() raises:
    """Test writing negative integer values."""
    var config = Dict[String, TomlValue]()
    config["temp"] = TomlValue(-42)

    var output = to_toml(config)
    assert_equal(output, "temp = -42\n")


fn test_write_float() raises:
    """Test writing float values."""
    var config = Dict[String, TomlValue]()
    config["pi"] = TomlValue(3.14159)

    var output = to_toml(config)
    assert_true(output.startswith("pi = 3.14"))


fn test_write_float_inf() raises:
    """Test writing positive infinity."""
    var config = Dict[String, TomlValue]()
    var pos_inf = Float64(1.0) / Float64(0.0)
    config["infinity"] = TomlValue(pos_inf)

    var output = to_toml(config)
    assert_equal(output, "infinity = inf\n")


fn test_write_float_neg_inf() raises:
    """Test writing negative infinity."""
    var config = Dict[String, TomlValue]()
    var neg_inf = Float64(-1.0) / Float64(0.0)
    config["neg_infinity"] = TomlValue(neg_inf)

    var output = to_toml(config)
    assert_equal(output, "neg_infinity = -inf\n")


fn test_write_float_nan() raises:
    """Test writing NaN."""
    var config = Dict[String, TomlValue]()
    var nan = Float64(0.0) / Float64(0.0)
    config["not_a_number"] = TomlValue(nan)

    var output = to_toml(config)
    assert_equal(output, "not_a_number = nan\n")


fn test_write_boolean_true() raises:
    """Test writing boolean true value."""
    var config = Dict[String, TomlValue]()
    config["enabled"] = TomlValue(True)

    var output = to_toml(config)
    assert_equal(output, "enabled = true\n")


fn test_write_boolean_false() raises:
    """Test writing boolean false value."""
    var config = Dict[String, TomlValue]()
    config["debug"] = TomlValue(False)

    var output = to_toml(config)
    assert_equal(output, "debug = false\n")


fn test_write_empty_array() raises:
    """Test writing an empty array."""
    var config = Dict[String, TomlValue]()
    var arr = List[TomlValue]()
    config["items"] = TomlValue(arr^)

    var output = to_toml(config)
    assert_equal(output, "items = []\n")


fn test_write_integer_array() raises:
    """Test writing an array of integers."""
    var config = Dict[String, TomlValue]()
    var arr = List[TomlValue]()
    arr.append(TomlValue(1))
    arr.append(TomlValue(2))
    arr.append(TomlValue(3))
    config["numbers"] = TomlValue(arr^)

    var output = to_toml(config)
    assert_equal(output, "numbers = [1, 2, 3]\n")


fn test_write_string_array() raises:
    """Test writing an array of strings."""
    var config = Dict[String, TomlValue]()
    var arr = List[TomlValue]()
    arr.append(TomlValue("red"))
    arr.append(TomlValue("green"))
    arr.append(TomlValue("blue"))
    config["colors"] = TomlValue(arr^)

    var output = to_toml(config)
    assert_equal(output, "colors = [\"red\", \"green\", \"blue\"]\n")


fn test_write_mixed_array() raises:
    """Test writing an array with mixed types."""
    var config = Dict[String, TomlValue]()
    var arr = List[TomlValue]()
    arr.append(TomlValue(1))
    arr.append(TomlValue("two"))
    arr.append(TomlValue(3.0))
    arr.append(TomlValue(True))
    config["mixed"] = TomlValue(arr^)

    var output = to_toml(config)
    assert_true(output.startswith("mixed = [1, \"two\", 3"))


fn test_write_nested_array() raises:
    """Test writing nested arrays."""
    var config = Dict[String, TomlValue]()

    var inner1 = List[TomlValue]()
    inner1.append(TomlValue(1))
    inner1.append(TomlValue(2))

    var inner2 = List[TomlValue]()
    inner2.append(TomlValue(3))
    inner2.append(TomlValue(4))

    var outer = List[TomlValue]()
    outer.append(TomlValue(inner1^))
    outer.append(TomlValue(inner2^))

    config["matrix"] = TomlValue(outer^)

    var output = to_toml(config)
    assert_equal(output, "matrix = [[1, 2], [3, 4]]\n")


fn test_write_multiple_keys() raises:
    """Test writing multiple key-value pairs."""
    var config = Dict[String, TomlValue]()
    config["name"] = TomlValue("test")
    config["port"] = TomlValue(8080)
    config["enabled"] = TomlValue(True)

    var output = to_toml(config)

    # Check that all keys are present (order may vary due to Dict)
    assert_true(output.find("name = \"test\"") != -1)
    assert_true(output.find("port = 8080") != -1)
    assert_true(output.find("enabled = true") != -1)


fn test_write_single_key_table() raises:
    """Test writing a single-key table (written inline)."""
    var config = Dict[String, TomlValue]()

    var data = Dict[String, TomlValue]()
    data["value"] = TomlValue(42)

    config["data"] = TomlValue(data^)

    var output = to_toml(config)
    # Single-key table can be inline
    assert_true(output.find("data = { value = 42 }") != -1 or output.find("[data]") != -1)


fn test_write_empty_string() raises:
    """Test writing an empty string value."""
    var config = Dict[String, TomlValue]()
    config["empty"] = TomlValue("")

    var output = to_toml(config)
    assert_equal(output, "empty = \"\"\n")


def main() raises:
    """Run all basic writer tests."""
    var suite = TestSuite()
    suite.test[test_write_string]()
    suite.test[test_write_string_with_escapes]()
    suite.test[test_write_string_with_quotes]()
    suite.test[test_write_string_with_backslash]()
    suite.test[test_write_integer]()
    suite.test[test_write_negative_integer]()
    suite.test[test_write_float]()
    suite.test[test_write_float_inf]()
    suite.test[test_write_float_neg_inf]()
    suite.test[test_write_float_nan]()
    suite.test[test_write_boolean_true]()
    suite.test[test_write_boolean_false]()
    suite.test[test_write_empty_array]()
    suite.test[test_write_integer_array]()
    suite.test[test_write_string_array]()
    suite.test[test_write_mixed_array]()
    suite.test[test_write_nested_array]()
    suite.test[test_write_multiple_keys]()
    suite.test[test_write_single_key_table]()
    suite.test[test_write_empty_string]()
    suite^.run()
