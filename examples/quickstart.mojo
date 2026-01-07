"""Quickstart example for mojo-toml.

This example mirrors the Quickstart section in README.md,
demonstrating basic TOML parsing and value access.
"""

from toml import parse


fn main() raises:
    print("🔥 mojo-toml - Quickstart Example")
    print("=" * 50)
    print()
    
    # Read TOML file
    var content: String
    with open("examples/quickstart.toml", "r") as f:
        content = f.read()
    
    # Parse and access values
    var config = parse(content)
    
    # Access nested tables
    var app = config["app"].as_table()
    print("App:", app["name"].as_string())
    print("Version:", app["version"].as_string())
    print()
    
    var db = config["database"].as_table()
    print("Database:", db["host"].as_string(), ":", db["port"].as_int())
    print("Timeout:", db["timeout"].as_float())
    print()
    
    # Access arrays
    var features = config["features"].as_table()["enabled"].as_array()
    print("Features enabled:", len(features))
    for i in range(len(features)):
        print("  -", features[i].as_string())
    print()
    
    print("✅ Successfully parsed quickstart.toml")
