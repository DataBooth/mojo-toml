"""Simple example: Parse and report pixi.toml configuration.

This example demonstrates basic usage of the mojo-toml parser by reading
the project's own pixi.toml file and displaying key configuration values.

Note: Currently only supports flat key-value pairs. Table support ([workspace])
will be added in future versions.
"""

from toml import parse


fn main():
    """Parse pixi.toml and display project information."""
    
    print("🔥 mojo-toml - Parse pixi.toml Example")
    print("=" * 50)
    print()
    
    # Try to parse pixi.toml
    try:
        var file_content: String = ""
        with open("pixi.toml", "r") as f:
            file_content = f.read()
        
        var config = parse(file_content)
        
        print("📋 Project Configuration")
        print("-" * 50)
        print("Found", config.__len__(), "configuration values")
        print()
        print("✅ Successfully parsed pixi.toml!")
        
    except:
        print("⚠️  Note: pixi.toml uses table syntax")
        print()
        print("The pixi.toml file contains table headers like:")
        print("  [workspace]")
        print("  [tasks]")
        print("  [dependencies]")
        print()
        print("Table support is coming soon!")
        print()
        print("The parser currently handles flat key-value pairs like:")
        print()
        print("  name = \"mojo-toml\"")
        print("  version = \"0.1.0\"")
        print("  debug = true")
        print("  port = 8080")
    
    print()
    print("Examples that work today:")
    print("  • Run: pixi run example-simple")
    print("  • Check fixtures/ directory")
    print("  • Run: pixi run test-fixtures")
