"""Simple example: Parse and report pixi.toml configuration.

This example demonstrates basic usage of the mojo-toml parser by reading
the project's own pixi.toml file and displaying key configuration values.
"""

from toml import parse


fn main():
    """Parse pixi.toml and display project information."""
    
    print("🔥 mojo-toml - Parse pixi.toml Example")
    print("=" * 50)
    print()
    
    # Try to parse pixi.toml
    try:
        var file_content: String
        with open("pixi.toml", "r") as f:
            file_content = f.read()
        
        var config = parse(file_content)
        
        print("📋 Project Configuration")
        print("-" * 50)
        print("Found", config.__len__(), "top-level keys")
        print()
        
        # Access workspace table
        if config.__contains__("workspace"):
            var workspace = config["workspace"].as_table()
            print("Project Name:", workspace["name"].as_string())
            print("Version:", workspace["version"].as_string())
            var platforms = workspace["platforms"].as_array()
            print("Platforms:", len(platforms), "items")
        
        print()
        print("✅ Successfully parsed pixi.toml!")
        print()
        print("Note: Values accessed using nested table structure:")
        print("  var workspace = config[\"workspace\"].as_table()")
        print("  var name = workspace[\"name\"].as_string()")
        
    except e:
        print("❌ Error parsing pixi.toml:", e)
    
    print()
    print("More examples:")
    print("  • Full demo: pixi run example-simple")
    print("  • Test suite: pixi run test-all")
    print("  • Check fixtures/ directory")
