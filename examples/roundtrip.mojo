"""Round-trip example: Parse TOML, modify it, and write it back.

This demonstrates how to:
1. Parse a TOML configuration file
2. Modify values in memory
3. Write the updated configuration back to TOML format
"""

from toml import parse, to_toml, TomlValue
from std.collections import Dict


def main() raises:
    print("🔥 mojo-toml - Round-trip Example")
    print("=" * 50)
    print()

    # Original TOML configuration
    var original_toml = """
# Application Configuration
title = "My Application"
version = "1.0.0"

[server]
host = "localhost"
port = 8080
debug = false

[database]
host = "db.example.com"
port = 5432
max_connections = 100
"""

    print("Original TOML:")
    print(original_toml)
    print()

    # Parse the TOML
    print("Parsing TOML...")
    var config = parse(original_toml)
    print("✓ Parsed successfully")
    print()

    # Modify values
    print("Modifying configuration:")
    config["version"] = TomlValue("2.0.0")
    print("  • Updated version to 2.0.0")

    var server = config["server"].as_table()
    server["port"] = TomlValue(9000)
    server["debug"] = TomlValue(True)
    config["server"] = TomlValue(server^)
    print("  • Changed server port to 9000")
    print("  • Enabled debug mode")

    var db = config["database"].as_table()
    db["max_connections"] = TomlValue(200)
    config["database"] = TomlValue(db^)
    print("  • Increased max_connections to 200")
    print()

    # Write back to TOML
    print("Writing updated configuration:")
    print("-" * 50)
    var updated_toml = to_toml(config)
    print(updated_toml)
    print("-" * 50)
    print()

    # Verify round-trip
    print("Verifying round-trip...")
    var reparsed = parse(updated_toml)
    print("  ✓ Version:", reparsed["version"].as_string())
    print("  ✓ Server port:", reparsed["server"].as_table()["port"].as_int())
    print("  ✓ Debug mode:", reparsed["server"].as_table()["debug"].as_bool())
    print("  ✓ Max connections:", reparsed["database"].as_table()["max_connections"].as_int())
    print()

    print("Round-trip successful! 🎉")
