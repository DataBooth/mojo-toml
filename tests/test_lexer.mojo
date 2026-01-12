"""Lexer tests for mojo-toml.

Comprehensive tests for the tokenisation of TOML input into token streams.
Covers all token types, syntax elements, and lexer functionality.
"""

from testing import assert_equal, assert_true, TestSuite
from toml.lexer import Lexer, TokenKind


fn test_empty_input() raises:
    """Test lexing empty input."""
    var lexer = Lexer("")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 1)
    assert_true(tokens[0].kind == TokenKind.EOF())


fn test_simple_key_value() raises:
    """Test basic key = value tokenisation."""
    var lexer = Lexer("name = \"mojo-toml\"")
    var tokens = lexer.tokenize()

    # Should be: KEY("name"), EQUALS, STRING("mojo-toml"), EOF
    assert_equal(len(tokens), 4)
    assert_true(tokens[0].kind == TokenKind.KEY())
    assert_equal(tokens[0].value, "name")
    assert_true(tokens[1].kind == TokenKind.EQUALS())
    assert_true(tokens[2].kind == TokenKind.STRING())
    assert_equal(tokens[2].value, "mojo-toml")
    assert_true(tokens[3].kind == TokenKind.EOF())


fn test_integers() raises:
    """Test integer tokenisation."""
    var test_cases = List[String]()
    test_cases.append("42")
    test_cases.append("+17")
    test_cases.append("-5")
    test_cases.append("1_000")
    test_cases.append("5_349_221")

    for i in range(len(test_cases)):
        var lexer = Lexer(test_cases[i])
        var tokens = lexer.tokenize()
        assert_true(tokens[0].kind == TokenKind.INTEGER(), msg="Expected INTEGER token")


fn test_floats() raises:
    """Test float tokenisation."""
    var test_cases = List[String]()
    test_cases.append("3.14")
    test_cases.append("1e10")
    test_cases.append("6.022e23")
    test_cases.append("-0.01")
    test_cases.append("+1.0")

    for i in range(len(test_cases)):
        var lexer = Lexer(test_cases[i])
        var tokens = lexer.tokenize()
        assert_true(tokens[0].kind == TokenKind.FLOAT(), msg="Expected FLOAT token")


fn test_special_floats() raises:
    """Test special float values (inf, nan)."""
    var lexer1 = Lexer("inf")
    var tokens1 = lexer1.tokenize()
    assert_true(tokens1[0].kind == TokenKind.FLOAT())
    assert_equal(tokens1[0].value, "inf")

    var lexer2 = Lexer("-inf")
    var tokens2 = lexer2.tokenize()
    assert_true(tokens2[0].kind == TokenKind.FLOAT())
    assert_equal(tokens2[0].value, "-inf")

    var lexer3 = Lexer("nan")
    var tokens3 = lexer3.tokenize()
    assert_true(tokens3[0].kind == TokenKind.FLOAT())
    assert_equal(tokens3[0].value, "nan")


fn test_booleans() raises:
    """Test boolean tokenisation."""
    var lexer1 = Lexer("true")
    var tokens1 = lexer1.tokenize()
    assert_true(tokens1[0].kind == TokenKind.BOOLEAN())
    assert_equal(tokens1[0].value, "true")

    var lexer2 = Lexer("false")
    var tokens2 = lexer2.tokenize()
    assert_true(tokens2[0].kind == TokenKind.BOOLEAN())
    assert_equal(tokens2[0].value, "false")


fn test_basic_string() raises:
    """Test basic string with escape sequences."""
    var lexer = Lexer('"hello world"')
    var tokens = lexer.tokenize()
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "hello world")


fn test_literal_string() raises:
    """Test literal string (no escape processing)."""
    var lexer = Lexer("'C:\\\\Users\\\\name'")
    var tokens = lexer.tokenize()
    assert_true(tokens[0].kind == TokenKind.STRING())
    # Literal strings preserve backslashes
    assert_equal(tokens[0].value, "C:\\\\Users\\\\name")


fn test_string_escapes() raises:
    """Test escape sequences in basic strings."""
    var lexer = Lexer('"line1\\nline2\\ttab"')
    var tokens = lexer.tokenize()
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "line1\nline2\ttab")


fn test_multiline_basic_string() raises:
    """Test multiline basic string with triple quotes."""
    var input = '"""line 1\nline 2\nline 3"""'
    var lexer = Lexer(input)
    var tokens = lexer.tokenize()
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "line 1\nline 2\nline 3")


fn test_comments() raises:
    """Test comment tokenisation."""
    var lexer = Lexer("# This is a comment")
    var tokens = lexer.tokenize()
    assert_true(tokens[0].kind == TokenKind.COMMENT())
    assert_equal(tokens[0].value, " This is a comment")


fn test_inline_comment() raises:
    """Test inline comment after value."""
    var lexer = Lexer('name = "value"  # comment')
    var tokens = lexer.tokenize()

    # KEY, EQUALS, STRING, COMMENT, EOF
    assert_equal(len(tokens), 5)
    assert_true(tokens[0].kind == TokenKind.KEY())
    assert_true(tokens[1].kind == TokenKind.EQUALS())
    assert_true(tokens[2].kind == TokenKind.STRING())
    assert_true(tokens[3].kind == TokenKind.COMMENT())
    assert_equal(tokens[3].value, " comment")


fn test_punctuation() raises:
    """Test all punctuation tokens."""
    var lexer = Lexer("= . , [ ] { }")
    var tokens = lexer.tokenize()

    assert_true(tokens[0].kind == TokenKind.EQUALS())
    assert_true(tokens[1].kind == TokenKind.DOT())
    assert_true(tokens[2].kind == TokenKind.COMMA())
    assert_true(tokens[3].kind == TokenKind.LEFT_BRACKET())
    assert_true(tokens[4].kind == TokenKind.RIGHT_BRACKET())
    assert_true(tokens[5].kind == TokenKind.LEFT_BRACE())
    assert_true(tokens[6].kind == TokenKind.RIGHT_BRACE())
    assert_true(tokens[7].kind == TokenKind.EOF())


fn test_array_syntax() raises:
    """Test array tokenisation."""
    var lexer = Lexer("[1, 2, 3]")
    var tokens = lexer.tokenize()

    # [, INT, COMMA, INT, COMMA, INT, ], EOF
    assert_true(tokens[0].kind == TokenKind.LEFT_BRACKET())
    assert_true(tokens[1].kind == TokenKind.INTEGER())
    assert_true(tokens[2].kind == TokenKind.COMMA())
    assert_true(tokens[3].kind == TokenKind.INTEGER())
    assert_true(tokens[4].kind == TokenKind.COMMA())
    assert_true(tokens[5].kind == TokenKind.INTEGER())
    assert_true(tokens[6].kind == TokenKind.RIGHT_BRACKET())


fn test_inline_table_syntax() raises:
    """Test inline table tokenisation."""
    var lexer = Lexer('{name = "value"}')
    var tokens = lexer.tokenize()

    # {, KEY, EQUALS, STRING, }, EOF
    assert_true(tokens[0].kind == TokenKind.LEFT_BRACE())
    assert_true(tokens[1].kind == TokenKind.KEY())
    assert_true(tokens[2].kind == TokenKind.EQUALS())
    assert_true(tokens[3].kind == TokenKind.STRING())
    assert_true(tokens[4].kind == TokenKind.RIGHT_BRACE())


fn test_table_header() raises:
    """Test table header tokenisation."""
    var lexer = Lexer("[package]")
    var tokens = lexer.tokenize()

    # [, KEY, ], EOF
    assert_true(tokens[0].kind == TokenKind.LEFT_BRACKET())
    assert_true(tokens[1].kind == TokenKind.KEY())
    assert_equal(tokens[1].value, "package")
    assert_true(tokens[2].kind == TokenKind.RIGHT_BRACKET())


fn test_dotted_key() raises:
    """Test dotted key tokenisation."""
    var lexer = Lexer("a.b.c = 1")
    var tokens = lexer.tokenize()

    # KEY, DOT, KEY, DOT, KEY, EQUALS, INT, EOF
    assert_true(tokens[0].kind == TokenKind.KEY())
    assert_equal(tokens[0].value, "a")
    assert_true(tokens[1].kind == TokenKind.DOT())
    assert_true(tokens[2].kind == TokenKind.KEY())
    assert_equal(tokens[2].value, "b")
    assert_true(tokens[3].kind == TokenKind.DOT())
    assert_true(tokens[4].kind == TokenKind.KEY())
    assert_equal(tokens[4].value, "c")
    assert_true(tokens[5].kind == TokenKind.EQUALS())
    assert_true(tokens[6].kind == TokenKind.INTEGER())


fn test_newlines() raises:
    """Test newline handling."""
    var lexer = Lexer("key1 = 1\nkey2 = 2")
    var tokens = lexer.tokenize()

    # KEY, EQUALS, INT, NEWLINE, KEY, EQUALS, INT, EOF
    assert_true(tokens[0].kind == TokenKind.KEY())
    assert_true(tokens[1].kind == TokenKind.EQUALS())
    assert_true(tokens[2].kind == TokenKind.INTEGER())
    assert_true(tokens[3].kind == TokenKind.NEWLINE())
    assert_true(tokens[4].kind == TokenKind.KEY())


fn test_whitespace_handling() raises:
    """Test whitespace is properly skipped."""
    var lexer = Lexer("  key  =  \"value\"  ")
    var tokens = lexer.tokenize()

    # Whitespace should be skipped, only meaningful tokens remain
    assert_true(tokens[0].kind == TokenKind.KEY())
    assert_true(tokens[1].kind == TokenKind.EQUALS())
    assert_true(tokens[2].kind == TokenKind.STRING())
    assert_true(tokens[3].kind == TokenKind.EOF())


fn test_position_tracking() raises:
    """Test that tokens track their position correctly."""
    var lexer = Lexer("key = 1\nname = \"value\"")
    var tokens = lexer.tokenize()

    # First token should be at line 1, column 1
    assert_equal(tokens[0].pos.line, 1)
    assert_equal(tokens[0].pos.column, 1)

    # Token after newline should be at line 2
    assert_equal(tokens[4].pos.line, 2)


fn test_unquoted_keys() raises:
    """Test various unquoted key formats."""
    var test_cases = List[String]()
    test_cases.append("simple")
    test_cases.append("snake_case")
    test_cases.append("kebab-case")
    test_cases.append("CamelCase")
    test_cases.append("key123")

    for i in range(len(test_cases)):
        var lexer = Lexer(test_cases[i])
        var tokens = lexer.tokenize()
        assert_true(tokens[0].kind == TokenKind.KEY())
        assert_equal(tokens[0].value, test_cases[i])


fn test_quoted_keys() raises:
    """Test quoted keys (allows any characters)."""
    var lexer = Lexer('"127.0.0.1" = "localhost"')
    var tokens = lexer.tokenize()

    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "127.0.0.1")
    assert_true(tokens[1].kind == TokenKind.EQUALS())
    assert_true(tokens[2].kind == TokenKind.STRING())


fn test_empty_string() raises:
    """Test empty string parsing."""
    var lexer = Lexer('name = ""')
    var tokens = lexer.tokenize()

    assert_true(tokens[2].kind == TokenKind.STRING())
    assert_equal(tokens[2].value, "")


fn test_number_with_underscores() raises:
    """Test numbers with underscore separators."""
    var lexer = Lexer("big = 1_000_000")
    var tokens = lexer.tokenize()

    assert_true(tokens[2].kind == TokenKind.INTEGER())
    # Underscores are stripped during tokenisation
    assert_equal(tokens[2].value, "1000000")


fn test_complex_toml_line() raises:
    """Test a realistic TOML line."""
    var lexer = Lexer('[package]\nname = "mojo-toml"  # First TOML parser\nversion = "0.1.0"')
    var tokens = lexer.tokenize()

    # Should handle table header, key-value pairs, and comments
    assert_true(tokens[0].kind == TokenKind.LEFT_BRACKET())
    assert_true(tokens[1].kind == TokenKind.KEY())
    assert_equal(tokens[1].value, "package")
    assert_true(tokens[2].kind == TokenKind.RIGHT_BRACKET())
    assert_true(tokens[3].kind == TokenKind.NEWLINE())
    assert_true(tokens[4].kind == TokenKind.KEY())
    assert_equal(tokens[4].value, "name")


def main():
    """Run all lexer tests."""
    from testing import TestSuite
    var suite = TestSuite()
    suite.test[test_empty_input]()
    suite.test[test_simple_key_value]()
    suite.test[test_integers]()
    suite.test[test_floats]()
    suite.test[test_special_floats]()
    suite.test[test_booleans]()
    suite.test[test_basic_string]()
    suite.test[test_literal_string]()
    suite.test[test_string_escapes]()
    suite.test[test_multiline_basic_string]()
    suite.test[test_comments]()
    suite.test[test_inline_comment]()
    suite.test[test_punctuation]()
    suite.test[test_array_syntax]()
    suite.test[test_inline_table_syntax]()
    suite.test[test_table_header]()
    suite.test[test_dotted_key]()
    suite.test[test_newlines]()
    suite.test[test_whitespace_handling]()
    suite.test[test_position_tracking]()
    suite.test[test_unquoted_keys]()
    suite.test[test_quoted_keys]()
    suite.test[test_empty_string]()
    suite.test[test_number_with_underscores]()
    suite.test[test_complex_toml_line]()
    suite^.run()
