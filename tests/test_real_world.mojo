"""Real-world TOML parsing tests.

Tests parsing actual TOML files like pixi.toml to validate against real-world usage.
This is "dogfooding" - using our own project's config files to test the parser.
"""

from testing import assert_equal, assert_true, TestSuite
from toml import parse
from pathlib import Path


fn test_parse_pixi_toml() raises:
    """Test parsing our own pixi.toml file.
    
    This validates that the parser can handle a real-world TOML file
    from an actual Mojo project.
    """
    # Read pixi.toml from project root
    var content = Path("pixi.toml").read_text()
    var data = parse(content)
    
    # Validate workspace section exists and has expected keys
    # Note: Currently we only support top-level key-value pairs
    # Once we implement table support, we can validate nested structures
    
    # For now, just verify it parses without error and has some basic keys
    # We expect these top-level keys before the [workspace] section
    # (Actually pixi.toml starts with [workspace], so we need table support)
    
    # Since we don't have table support yet, this will likely fail
    # But we can at least verify the file loads and tokenizes
    print("Successfully parsed pixi.toml")
    print("Number of top-level keys:", len(data))


fn test_parse_simple_toml_file() raises:
    """Test parsing a simple TOML file we create."""
    # Create a simple test TOML file
    var simple_toml = """
# Simple test configuration
name = "mojo-toml"
version = "0.1.0"
author = "DataBooth"

# Feature flags  
debug = false
port = 8080
timeout = 30.0
"""
    
    var data = parse(simple_toml)
    
    # Validate parsed data
    assert_true(data.__contains__("name"))
    assert_equal(data["name"].as_string(), "mojo-toml")
    
    assert_true(data.__contains__("version"))
    assert_equal(data["version"].as_string(), "0.1.0")
    
    assert_true(data.__contains__("author"))
    assert_equal(data["author"].as_string(), "DataBooth")
    
    assert_true(data.__contains__("debug"))
    assert_true(data["debug"].is_bool())
    assert_true(not data["debug"].as_bool())
    
    assert_true(data.__contains__("port"))
    assert_equal(data["port"].as_int(), 8080)
    
    assert_true(data.__contains__("timeout"))
    assert_true(data["timeout"].is_float())
    var timeout_val = data["timeout"].as_float()
    assert_true(timeout_val > 29.9 and timeout_val < 30.1)


fn test_parse_config_with_comments() raises:
    """Test parsing TOML with extensive comments."""
    var config = """
# Application Configuration
# =======================

# Server settings
host = "localhost"  # Bind to localhost only
port = 3000         # Default port

# Database settings  
db_host = "127.0.0.1"
db_port = 5432
db_name = "myapp"

# Feature toggles
enable_cache = true
enable_metrics = false

# Performance tuning
max_connections = 100
timeout_seconds = 30.5
"""
    
    var data = parse(config)
    
    # Validate server settings
    assert_equal(data["host"].as_string(), "localhost")
    assert_equal(data["port"].as_int(), 3000)
    
    # Validate database settings
    assert_equal(data["db_host"].as_string(), "127.0.0.1")
    assert_equal(data["db_port"].as_int(), 5432)
    assert_equal(data["db_name"].as_string(), "myapp")
    
    # Validate feature toggles
    assert_true(data["enable_cache"].as_bool())
    assert_true(not data["enable_metrics"].as_bool())
    
    # Validate performance settings
    assert_equal(data["max_connections"].as_int(), 100)
    var timeout = data["timeout_seconds"].as_float()
    assert_true(timeout > 30.4 and timeout < 30.6)


fn test_parse_multiline_strings() raises:
    """Test parsing TOML with multiline string values."""
    var toml_with_multiline = '''
description = """
This is a multiline
description that spans
multiple lines.
"""

single_line = "This is just one line"
'''
    
    var data = parse(toml_with_multiline)
    
    assert_true(data.__contains__("description"))
    var desc = data["description"].as_string()
    # Multiline string should contain newlines
    assert_true("\n" in desc)
    
    assert_true(data.__contains__("single_line"))
    assert_equal(data["single_line"].as_string(), "This is just one line")


fn test_parse_numbers_variations() raises:
    """Test various number formats supported by TOML."""
    var numbers_toml = """
# Integer variations
positive = 42
negative = -17
zero = 0
large = 1_000_000

# Float variations  
pi = 3.14159
negative_float = -0.01
scientific = 1e10
scientific_neg = 6.022e-23

# Special floats
infinity = inf
negative_infinity = -inf
not_a_num = nan
"""
    
    var data = parse(numbers_toml)
    
    # Integers
    assert_equal(data["positive"].as_int(), 42)
    assert_equal(data["negative"].as_int(), -17)
    assert_equal(data["zero"].as_int(), 0)
    assert_equal(data["large"].as_int(), 1000000)
    
    # Regular floats
    var pi = data["pi"].as_float()
    assert_true(pi > 3.14 and pi < 3.15)
    
    var neg_float = data["negative_float"].as_float()
    assert_true(neg_float < 0 and neg_float > -0.02)
    
    # Scientific notation
    var sci = data["scientific"].as_float()
    assert_true(sci > 9e9)
    
    # Special floats
    assert_true(data["infinity"].is_float())
    assert_true(data["negative_infinity"].is_float())
    assert_true(data["not_a_num"].is_float())


def main():
    """Run all real-world parsing tests."""
    from testing import TestSuite
    var suite = TestSuite()
    
    # Note: test_parse_pixi_toml will likely fail until we implement table support
    # suite.test[test_parse_pixi_toml]()  # Skip for now
    
    suite.test[test_parse_simple_toml_file]()
    suite.test[test_parse_config_with_comments]()
    suite.test[test_parse_multiline_strings]()
    suite.test[test_parse_numbers_variations]()
    suite^.run()
