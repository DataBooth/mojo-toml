"""Comprehensive example: Parse and report pixi.toml configuration.

This example demonstrates advanced usage of the mojo-toml parser by reading
the project's own pixi.toml file and generating a detailed report of its contents.
"""

from toml import parse


fn main():
    """Parse pixi.toml and generate comprehensive report."""
    
    print("🔥 mojo-toml - Pixi Configuration Report")
    print("=" * 60)
    print()
    
    # Try to parse pixi.toml
    try:
        var file_content: String
        with open("pixi.toml", "r") as f:
            file_content = f.read()
        
        var config = parse(file_content)
        
        print("📊 Configuration Summary")
        print("-" * 60)
        print("Top-level sections:", config.__len__())
        print()
        
        # Workspace section
        if config.__contains__("workspace"):
            var workspace = config["workspace"].as_table()
            print("📦 Workspace Information:")
            print("  Name:", workspace["name"].as_string())
            print("  Version:", workspace["version"].as_string())
            var platforms = workspace["platforms"].as_array()
            print("  Platforms:", len(platforms), "configured")
            var channels = workspace["channels"].as_array()
            print("  Channels:", len(channels), "configured")
            print()
        
        # Dependencies section
        if config.__contains__("dependencies"):
            var deps = config["dependencies"].as_table()
            var dep_count = 0
            for _ in deps.items():
                dep_count += 1
            print("📚 Dependencies:")
            print("  Total packages:", dep_count)
            print()
        
        # Tasks section
        if config.__contains__("tasks"):
            var tasks = config["tasks"].as_table()
            var task_count = 0
            var test_count = 0
            var build_count = 0
            var example_count = 0
            for entry in tasks.items():
                task_count += 1
                if entry.key.startswith("test-"):
                    test_count += 1
                elif entry.key.startswith("build-"):
                    build_count += 1
                elif entry.key.startswith("example-"):
                    example_count += 1
            print("🛠️  Tasks:")
            print("  Total tasks:", task_count)
            print("  Test tasks:", test_count)
            print("  Build tasks:", build_count)
            print("  Example tasks:", example_count)
            print()
        
        # Activation section
        if config.__contains__("activation"):
            var activation = config["activation"].as_table()
            if activation.__contains__("env"):
                var env = activation["env"].as_table()
                var env_count = 0
                for _ in env.items():
                    env_count += 1
                print("⚙️  Activation:")
                print("  Environment variables:", env_count)
                print()
        
        print("-" * 60)
        print("✅ Successfully parsed and analyzed pixi.toml!")
        print()
        print("💡 API usage demonstrated:")
        print("  • config[\"workspace\"].as_table()  # Access nested tables")
        print("  • workspace[\"name\"].as_string()  # Get string values")
        print("  • workspace[\"platforms\"].as_array()  # Get arrays")
        print("  • for entry in table.items()  # Iterate table entries")
        
    except e:
        print("❌ Error parsing pixi.toml:", e)
    
    print()
    print("📖 More resources:")
    print("  • Basic demo: pixi run example-simple")
    print("  • Run tests: pixi run test-all")
    print("  • See fixtures/ for more TOML examples")
