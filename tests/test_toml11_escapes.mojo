"""Tests for TOML 1.1 escape sequences (backslash-e and backslash-xHH).

Tests the TOML 1.1 additions:
- backslash-e for escape character (U+001B)
- backslash-xHH for codepoints 0-255
"""

from testing import assert_equal
from toml import parse, to_toml


fn test_escape_character() raises:
    """Test backslash-e escape for ESC character (TOML 1.1)."""
    # Double-escape for Mojo compiler, will be single backslash in string
    var toml = '''csi = "\\e["'''
    var data = parse(toml)
    
    # backslash-e should parse to ESC character (0x1B)
    var csi = data["csi"].as_string()
    assert_equal(ord(csi[0]), 0x1B)
    assert_equal(String(csi[1]), "[")


fn test_xhh_escape_letter_a() raises:
    """Test backslash-xHH for regular ASCII characters."""
    var toml = '''letter = "\\x61"'''
    var data = parse(toml)
    assert_equal(data["letter"].as_string(), "a")  # 0x61 = 'a'


fn test_xhh_escape_null_byte() raises:
    """Test backslash-x00 escape for null byte."""
    var toml = '''str = "null:\\x00end"'''
    var data = parse(toml)
    var s = data["str"].as_string()
    assert_equal(ord(s[5]), 0)  # Null byte at position 5


fn test_xhh_invalid_single_digit() raises:
    """Test that backslash-xH (single digit) raises an error."""
    var toml = '''bad = "test\\x1"'''
    try:
        _ = parse(toml)
        raise Error("Should have raised error for single hex digit")
    except:
        pass  # Expected


fn test_xhh_invalid_non_hex() raises:
    """Test that backslash-xGG (non-hex) raises an error."""
    var toml = '''bad = "test\\xGG"'''
    try:
        _ = parse(toml)
        raise Error("Should have raised error for non-hex characters")
    except:
        pass  # Expected




def main():
    """Run TOML 1.1 escape sequence tests."""
    from testing import TestSuite
    var suite = TestSuite()
    
    suite.test[test_escape_character]()
    suite.test[test_xhh_escape_letter_a]()
    suite.test[test_xhh_escape_null_byte]()
    suite.test[test_xhh_invalid_single_digit]()
    suite.test[test_xhh_invalid_non_hex]()
    
    suite^.run()
