"""Array tests for mojo-toml.

Tests TOML array parsing including homogeneous and heterogeneous arrays,
nested arrays, multiline arrays, and arrays with trailing commas.
"""

from testing import assert_equal, assert_true, assert_false, TestSuite
from toml import parse


fn test_empty_array() raises:
    """Test parsing empty array."""
    var data = parse("items = []")

    assert_true(data.__contains__("items"))
    assert_true(data["items"].is_array())

    var arr = data["items"].as_array()
    assert_equal(len(arr), 0)


fn test_integer_array() raises:
    """Test parsing array of integers."""
    var data = parse("numbers = [1, 2, 3, 4, 5]")

    assert_true(data["numbers"].is_array())
    var arr = data["numbers"].as_array()

    assert_equal(len(arr), 5)
    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_int(), 2)
    assert_equal(arr[2].as_int(), 3)
    assert_equal(arr[3].as_int(), 4)
    assert_equal(arr[4].as_int(), 5)


fn test_string_array() raises:
    """Test parsing array of strings."""
    var data = parse('colors = ["red", "green", "blue"]')

    assert_true(data["colors"].is_array())
    var arr = data["colors"].as_array()

    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_string(), "red")
    assert_equal(arr[1].as_string(), "green")
    assert_equal(arr[2].as_string(), "blue")


fn test_float_array() raises:
    """Test parsing array of floats."""
    var data = parse("values = [1.0, 2.5, 3.14]")

    assert_true(data["values"].is_array())
    var arr = data["values"].as_array()

    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_float(), 1.0)
    assert_equal(arr[1].as_float(), 2.5)
    assert_equal(arr[2].as_float(), 3.14)


fn test_boolean_array() raises:
    """Test parsing array of booleans."""
    var data = parse("flags = [true, false, true]")

    assert_true(data["flags"].is_array())
    var arr = data["flags"].as_array()

    assert_equal(len(arr), 3)
    assert_true(arr[0].as_bool())
    assert_false(arr[1].as_bool())
    assert_true(arr[2].as_bool())


fn test_mixed_type_array() raises:
    """Test parsing array with mixed types (valid in TOML)."""
    var data = parse('mixed = [1, "two", 3.0, true]')

    assert_true(data["mixed"].is_array())
    var arr = data["mixed"].as_array()

    assert_equal(len(arr), 4)
    assert_true(arr[0].is_int())
    assert_true(arr[1].is_string())
    assert_true(arr[2].is_float())
    assert_true(arr[3].is_bool())

    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_string(), "two")
    assert_equal(arr[2].as_float(), 3.0)
    assert_true(arr[3].as_bool())


fn test_nested_array() raises:
    """Test parsing nested arrays."""
    var data = parse("matrix = [[1, 2], [3, 4], [5, 6]]")

    assert_true(data["matrix"].is_array())
    var matrix = data["matrix"].as_array()

    assert_equal(len(matrix), 3)

    # Check first row
    assert_true(matrix[0].is_array())
    var row1 = matrix[0].as_array()
    assert_equal(len(row1), 2)
    assert_equal(row1[0].as_int(), 1)
    assert_equal(row1[1].as_int(), 2)

    # Check second row
    var row2 = matrix[1].as_array()
    assert_equal(row2[0].as_int(), 3)
    assert_equal(row2[1].as_int(), 4)

    # Check third row
    var row3 = matrix[2].as_array()
    assert_equal(row3[0].as_int(), 5)
    assert_equal(row3[1].as_int(), 6)


fn test_array_with_trailing_comma() raises:
    """Test parsing array with trailing comma."""
    var data = parse("items = [1, 2, 3,]")

    assert_true(data["items"].is_array())
    var arr = data["items"].as_array()

    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_int(), 2)
    assert_equal(arr[2].as_int(), 3)


fn test_multiline_array() raises:
    """Test parsing multiline array."""
    var data = parse("""items = [
    1,
    2,
    3
]""")

    assert_true(data["items"].is_array())
    var arr = data["items"].as_array()

    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_int(), 2)
    assert_equal(arr[2].as_int(), 3)


fn test_array_with_comments() raises:
    """Test parsing array with comments."""
    var data = parse("""items = [
    1,  # first item
    2,  # second item
    3   # third item
]""")

    assert_true(data["items"].is_array())
    var arr = data["items"].as_array()

    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_int(), 2)
    assert_equal(arr[2].as_int(), 3)


fn test_array_single_element() raises:
    """Test parsing single-element array."""
    var data = parse("singleton = [42]")

    assert_true(data["singleton"].is_array())
    var arr = data["singleton"].as_array()

    assert_equal(len(arr), 1)
    assert_equal(arr[0].as_int(), 42)


fn test_array_with_whitespace() raises:
    """Test parsing array with extra whitespace."""
    var data = parse("spaced = [  1  ,  2  ,  3  ]")

    assert_true(data["spaced"].is_array())
    var arr = data["spaced"].as_array()

    assert_equal(len(arr), 3)
    assert_equal(arr[0].as_int(), 1)
    assert_equal(arr[1].as_int(), 2)
    assert_equal(arr[2].as_int(), 3)


fn test_deeply_nested_array() raises:
    """Test parsing deeply nested arrays."""
    var data = parse("deep = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]")

    assert_true(data["deep"].is_array())
    var level1 = data["deep"].as_array()
    assert_equal(len(level1), 2)

    # First group [[1, 2], [3, 4]]
    var level2_1 = level1[0].as_array()
    assert_equal(len(level2_1), 2)

    var level3_1 = level2_1[0].as_array()
    assert_equal(level3_1[0].as_int(), 1)
    assert_equal(level3_1[1].as_int(), 2)

    var level3_2 = level2_1[1].as_array()
    assert_equal(level3_2[0].as_int(), 3)
    assert_equal(level3_2[1].as_int(), 4)


fn test_multiple_arrays() raises:
    """Test parsing multiple arrays in one document."""
    var data = parse("""
first = [1, 2, 3]
second = ["a", "b", "c"]
third = [true, false]
""")

    assert_true(data["first"].is_array())
    assert_true(data["second"].is_array())
    assert_true(data["third"].is_array())

    var arr1 = data["first"].as_array()
    assert_equal(len(arr1), 3)
    assert_equal(arr1[0].as_int(), 1)

    var arr2 = data["second"].as_array()
    assert_equal(len(arr2), 3)
    assert_equal(arr2[0].as_string(), "a")

    var arr3 = data["third"].as_array()
    assert_equal(len(arr3), 2)
    assert_true(arr3[0].as_bool())


def main():
    """Run all array tests."""
    var suite = TestSuite()
    suite.test[test_empty_array]()
    suite.test[test_integer_array]()
    suite.test[test_string_array]()
    suite.test[test_float_array]()
    suite.test[test_boolean_array]()
    suite.test[test_mixed_type_array]()
    suite.test[test_nested_array]()
    suite.test[test_array_with_trailing_comma]()
    suite.test[test_multiline_array]()
    suite.test[test_array_with_comments]()
    suite.test[test_array_single_element]()
    suite.test[test_array_with_whitespace]()
    suite.test[test_deeply_nested_array]()
    suite.test[test_multiple_arrays]()
    suite^.run()
