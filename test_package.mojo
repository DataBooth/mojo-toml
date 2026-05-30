from toml import parse, to_toml

fn main() raises:
    # Parse a simple TOML document
    let config = parse("""
[package]
name = "mojo-toml"
version = "0.9.1"
""")

    if config["package"].as_table()["name"].as_string() != "mojo-toml":
        raise Error("Parse failed: expected package.name = 'mojo-toml'")

    # Write TOML back out and check for key substrings
    let toml_str = to_toml(config)
    if not ("[package]" in toml_str and "name = \"mojo-toml\"" in toml_str):
        raise Error("Write failed: expected [package] with name = \"mojo-toml\"")

    print("ok")
