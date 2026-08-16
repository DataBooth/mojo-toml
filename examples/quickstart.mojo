"""Quickstart example for mojo-toml.

This example mirrors the Quickstart section in README.md,
demonstrating both reading and writing TOML files.
"""

from toml import parse, to_toml, TomlValue


def main() raises:
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
    print()
    print("=" * 50)
    print("🔥 Writing TOML")
    print("=" * 50)
    print()

    # Build configuration programmatically
    var new_config = Dict[String, TomlValue]()

    # Create app section
    var new_app = Dict[String, TomlValue]()
    new_app["name"] = TomlValue("QuickStart")
    new_app["version"] = TomlValue("2.0.0")
    new_app["debug"] = TomlValue(True)
    new_config["app"] = TomlValue(new_app^)

    # Create database section
    var new_db = Dict[String, TomlValue]()
    new_db["host"] = TomlValue("localhost")
    new_db["port"] = TomlValue(5432)
    new_db["timeout"] = TomlValue(30.5)
    new_config["database"] = TomlValue(new_db^)

    # Create features array
    var enabled = List[TomlValue]()
    enabled.append(TomlValue("auth"))
    enabled.append(TomlValue("logging"))
    enabled.append(TomlValue("metrics"))
    var new_features = Dict[String, TomlValue]()
    new_features["enabled"] = TomlValue(enabled^)
    new_config["features"] = TomlValue(new_features^)

    # Convert to TOML and write to file
    var toml_str = to_toml(new_config)
    with open("examples/quickstart_output.toml", "w") as f:
        f.write(toml_str)

    print("✅ Configuration written to quickstart_output.toml")
    print()
    print("Generated TOML:")
    print(toml_str)
