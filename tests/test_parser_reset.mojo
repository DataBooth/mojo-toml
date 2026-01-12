"""Test parser reset functionality.

Verifies that Parser.reset() allows reusing the same parser instance.
"""

from testing import assert_equal, assert_true, TestSuite
from toml.lexer import Lexer
from toml.parser import Parser


fn test_parser_reset_simple() raises:
    """Test that parser can be reset and reused."""
    # Parse first document
    var lexer1 = Lexer("name = \"first\"")
    var tokens1 = lexer1.tokenize()
    var parser = Parser(tokens1^)
    var data1 = parser.parse()

    assert_equal(data1["name"].as_string(), "first")

    # Reset and parse second document
    var lexer2 = Lexer("name = \"second\"")
    var tokens2 = lexer2.tokenize()
    parser.reset(tokens2^)
    var data2 = parser.parse()

    assert_equal(data2["name"].as_string(), "second")


fn test_parser_reset_complex() raises:
    """Test parser reset with complex TOML structures."""
    # First document with table
    var lexer1 = Lexer("""
[section1]
key = "value1"
""")
    var tokens1 = lexer1.tokenize()
    var parser = Parser(tokens1^)
    var data1 = parser.parse()

    var section1 = data1["section1"].as_table()
    assert_equal(section1["key"].as_string(), "value1")

    # Second document with different table
    var lexer2 = Lexer("""
[section2]
key = "value2"
port = 8080
""")
    var tokens2 = lexer2.tokenize()
    parser.reset(tokens2^)
    var data2 = parser.parse()

    var section2 = data2["section2"].as_table()
    assert_equal(section2["key"].as_string(), "value2")
    assert_equal(section2["port"].as_int(), 8080)


fn test_parser_reset_multiple_times() raises:
    """Test resetting parser multiple times."""
    # Create initial parser
    var lexer0 = Lexer("count = 0")
    var tokens0 = lexer0.tokenize()
    var parser = Parser(tokens0^)
    var data0 = parser.parse()
    assert_equal(data0["count"].as_int(), 0)

    # Reset and parse again
    var lexer1 = Lexer("count = 1")
    var tokens1 = lexer1.tokenize()
    parser.reset(tokens1^)
    var data1 = parser.parse()
    assert_equal(data1["count"].as_int(), 1)

    # Reset and parse third time
    var lexer2 = Lexer("count = 2")
    var tokens2 = lexer2.tokenize()
    parser.reset(tokens2^)
    var data2 = parser.parse()
    assert_equal(data2["count"].as_int(), 2)


def main():
    """Run all parser reset tests."""
    var suite = TestSuite()
    suite.test[test_parser_reset_simple]()
    suite.test[test_parser_reset_complex]()
    suite.test[test_parser_reset_multiple_times]()
    suite^.run()
