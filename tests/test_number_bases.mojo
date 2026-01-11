"""Tests for alternative number bases (hex, octal, binary).

Tests TOML 1.0 alternative integer formats:
- Hexadecimal: 0xDEAD, 0xdead_beef
- Octal: 0o755, 0o0755
- Binary: 0b1101, 0b1111_0000
"""

from testing import assert_equal
from toml import parse


fn test_hex_lowercase() raises:
    """Test lowercase hexadecimal integers."""
    var toml = "value = 0xdead"
    var data = parse(toml)
    var value = data["value"].as_int()
    # 0xDEAD = 57005
    assert_equal(value, 57005)


fn test_hex_uppercase() raises:
    """Test uppercase hexadecimal integers."""
    var toml = "value = 0xDEAD"
    var data = parse(toml)
    var value = data["value"].as_int()
    assert_equal(value, 57005)


fn test_hex_mixed_case() raises:
    """Test mixed case hexadecimal integers."""
    var toml = "value = 0xDeAd"
    var data = parse(toml)
    var value = data["value"].as_int()
    assert_equal(value, 57005)


fn test_hex_with_underscores() raises:
    """Test hexadecimal with underscores for readability."""
    var toml = "value = 0xdead_beef"
    var data = parse(toml)
    var value = data["value"].as_int()
    # 0xDEAD_BEEF = 3735928559
    assert_equal(value, 3735928559)


fn test_hex_simple() raises:
    """Test simple hexadecimal values."""
    var toml = "a = 0xFF\nb = 0x00\nc = 0x10"
    var data = parse(toml)
    assert_equal(data["a"].as_int(), 255)
    assert_equal(data["b"].as_int(), 0)
    assert_equal(data["c"].as_int(), 16)


fn test_octal_basic() raises:
    """Test basic octal integers."""
    var toml = "value = 0o755"
    var data = parse(toml)
    var value = data["value"].as_int()
    # 0o755 = 493
    assert_equal(value, 493)


fn test_octal_with_leading_zero() raises:
    """Test octal with leading zero."""
    var toml = "value = 0o0755"
    var data = parse(toml)
    var value = data["value"].as_int()
    assert_equal(value, 493)


fn test_octal_with_underscores() raises:
    """Test octal with underscores."""
    var toml = "value = 0o7_5_5"
    var data = parse(toml)
    var value = data["value"].as_int()
    assert_equal(value, 493)


fn test_octal_zero() raises:
    """Test octal zero."""
    var toml = "value = 0o0"
    var data = parse(toml)
    var value = data["value"].as_int()
    assert_equal(value, 0)


fn test_binary_basic() raises:
    """Test basic binary integers."""
    var toml = "value = 0b1101"
    var data = parse(toml)
    var value = data["value"].as_int()
    # 0b1101 = 13
    assert_equal(value, 13)


fn test_binary_with_underscores() raises:
    """Test binary with underscores."""
    var toml = "value = 0b1111_0000"
    var data = parse(toml)
    var value = data["value"].as_int()
    # 0b1111_0000 = 240
    assert_equal(value, 240)


fn test_binary_byte() raises:
    """Test binary byte values."""
    var toml = "a = 0b11111111\nb = 0b00000000\nc = 0b10101010"
    var data = parse(toml)
    assert_equal(data["a"].as_int(), 255)
    assert_equal(data["b"].as_int(), 0)
    assert_equal(data["c"].as_int(), 170)


fn test_mixed_bases() raises:
    """Test document with mixed number bases."""
    var toml = """
    decimal = 42
    hex = 0xFF
    octal = 0o755
    binary = 0b1010
    """
    var data = parse(toml)
    assert_equal(data["decimal"].as_int(), 42)
    assert_equal(data["hex"].as_int(), 255)
    assert_equal(data["octal"].as_int(), 493)
    assert_equal(data["binary"].as_int(), 10)


fn test_bases_in_array() raises:
    """Test alternative bases in arrays."""
    var toml = "values = [0xFF, 0o77, 0b11, 42]"
    var data = parse(toml)
    var arr = data["values"].as_array()
    assert_equal(arr[0].as_int(), 255)
    assert_equal(arr[1].as_int(), 63)  # 0o77 = 63
    assert_equal(arr[2].as_int(), 3)
    assert_equal(arr[3].as_int(), 42)


def main():
    """Run all alternative number base tests."""
    from testing import TestSuite
    var suite = TestSuite()
    suite.test[test_hex_lowercase]()
    suite.test[test_hex_uppercase]()
    suite.test[test_hex_mixed_case]()
    suite.test[test_hex_with_underscores]()
    suite.test[test_hex_simple]()
    suite.test[test_octal_basic]()
    suite.test[test_octal_with_leading_zero]()
    suite.test[test_octal_with_underscores]()
    suite.test[test_octal_zero]()
    suite.test[test_binary_basic]()
    suite.test[test_binary_with_underscores]()
    suite.test[test_binary_byte]()
    suite.test[test_mixed_bases]()
    suite.test[test_bases_in_array]()
    suite^.run()
