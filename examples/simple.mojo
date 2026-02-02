"""Simple example: Basic usage of mojo-toml parser.

This example demonstrates how to parse TOML files and access values.
"""

from toml import parse


fn main() raises:
    """Demonstrate basic TOML parsing with a simple configuration."""

    print("🔥 mojo-toml - Simple Example")
    print("=" * 50)
    print()

    # Example 1: Parse inline TOML string
    print("Example 1: Parse inline TOML")
    print("-" * 50)

    var config = parse("""
# Application settings
name = "my-app"
version = "1.0.0"
port = 8080
debug = false
timeout = 30.5
""")

    print("  Application:", config["name"].as_string())
    print("  Version:    ", config["version"].as_string())
    print("  Port:       ", config["port"].as_int())
    print("  Debug mode: ", config["debug"].as_bool())
    print("  Timeout:    ", config["timeout"].as_float(), "s")
    print()

    # Example 2: Parse a fixture file
    print("Example 2: Parse fixture file")
    print("-" * 50)

    var file_content: String
    with open("fixtures/app_config.toml", "r") as f:
        file_content = f.read()

    var app_config = parse(file_content)

    print("  App name:   ", app_config["app_name"].as_string())
    print("  Version:    ", app_config["version"].as_string())
    print("  License:    ", app_config["license"].as_string())
    print("  Port:       ", app_config["port"].as_int())
    print("  Host:       ", app_config["host"].as_string())
    print("  Debug:      ", app_config["debug"].as_bool())
    print("  DB timeout: ", app_config["db_timeout"].as_float(), "s")
    print("  Max conns:  ", app_config["max_connections"].as_int())
    print()

    # Example 3: Type checking
    print("Example 3: Type checking")
    print("-" * 50)

    var settings = parse('title = "Test"\ncount = 42\nratio = 3.14\nenabled = true')

    print("  'title' is string:", settings["title"].is_string())
    print("  'count' is int:   ", settings["count"].is_int())
    print("  'ratio' is float: ", settings["ratio"].is_float())
    print("  'enabled' is bool:", settings["enabled"].is_bool())
    print()

    # Example 4: Special float values
    print("Example 4: Special float values")
    print("-" * 50)

    var special = parse("pos_inf = inf\nneg_inf = -inf\nnot_a_num = nan")

    var pos_inf_val = special["pos_inf"].as_float()
    var neg_inf_val = special["neg_inf"].as_float()
    var nan_val = special["not_a_num"].as_float()

    print("  Positive infinity:", pos_inf_val)
    print("  Negative infinity:", neg_inf_val)
    print("  Not a number:     ", nan_val)
    print()

    print("✅ All examples complete!")
    print()
    print("Current parser capabilities:")
    print("  ✅ Strings (basic, literal, multiline)")
    print("  ✅ Integers (with underscores)")
    print("  ✅ Floats (scientific notation, inf, nan)")
    print("  ✅ Booleans")
    print("  ✅ Comments")
    print()
    print("Coming soon:")
    print("  ⏳ Arrays")
    print("  ⏳ Inline tables")
    print("  ⏳ Table headers [section]")
    print("  ⏳ Nested structures")
