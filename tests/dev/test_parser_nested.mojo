"""Test parser with nested table structures."""

from toml import parse

def main() raises:
    print("Testing nested table parsing:")
    print()

    var config = parse("""
[database]
host = "localhost"
port = 5432

[server]
host = "0.0.0.0"
port = 8080
""")

    print("✅ Parsed TOML with table headers!")
    print()

    # Test nested access
    var db = config["database"].as_table()
    print("Database host:", db["host"].as_string())
    print("Database port:", db["port"].as_int())

    var srv = config["server"].as_table()
    print("Server host:", srv["host"].as_string())
    print("Server port:", srv["port"].as_int())

    print()
    print("✅ Success! Nested table access works!")
