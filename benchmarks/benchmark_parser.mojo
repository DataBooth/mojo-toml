"""Performance benchmark for mojo-toml parser.

Measures parsing performance with various TOML document sizes and complexities.
"""

from time import perf_counter
from toml import parse
from pathlib import Path


fn format_time(seconds: Float64) -> String:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return String(Int(seconds * 1_000_000)) + " μs"
    elif seconds < 1.0:
        return String(Int(seconds * 1_000)) + " ms"
    else:
        return String(seconds) + " s"


fn benchmark_simple_parse() raises:
    """Benchmark simple key-value parsing."""
    var toml_content = """
title = "TOML Benchmark"
version = "1.0.0"
enabled = true
count = 42
pi = 3.14159
"""
    
    var iterations = 1000
    var start = perf_counter()
    
    for i in range(iterations):
        var data = parse(toml_content)
    
    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)
    
    print("Simple parse (5 keys):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_nested_tables() raises:
    """Benchmark nested table parsing."""
    var toml_content = """
[database]
host = "localhost"
port = 5432

[database.primary]
host = "db1.example.com"
port = 5432

[database.replica]
host = "db2.example.com"
port = 5433

[server]
host = "0.0.0.0"
port = 8080
"""
    
    var iterations = 1000
    var start = perf_counter()
    
    for i in range(iterations):
        var data = parse(toml_content)
    
    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)
    
    print("\nNested tables (3 tables, 7 keys):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_arrays() raises:
    """Benchmark array parsing."""
    var toml_content = """
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
mixed = [1, "two", 3.0, true, [5, 6], {key = "value"}]
nested = [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]]
"""
    
    var iterations = 1000
    var start = perf_counter()
    
    for i in range(iterations):
        var data = parse(toml_content)
    
    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)
    
    print("\nArrays (4 arrays, ~40 elements):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_dotted_keys() raises:
    """Benchmark dotted key parsing."""
    var toml_content = """
a.b.c = 1
a.b.d = 2
a.e.f = 3
a.e.g = 4
x.y.z = "deep"
server.host = "localhost"
server.port = 8080
server.ssl.enabled = true
server.ssl.cert = "/path/to/cert"
"""
    
    var iterations = 1000
    var start = perf_counter()
    
    for i in range(iterations):
        var data = parse(toml_content)
    
    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)
    
    print("\nDotted keys (9 keys creating nested structure):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_large_document() raises:
    """Benchmark large document with mixed complexity."""
    var toml_content = """
[package]
name = "mojo-toml"
version = "0.2.0"
description = "TOML parser for Mojo"
authors = ["DataBooth"]
license = "MIT"
repository = "https://github.com/databooth/mojo-toml"
keywords = ["toml", "parser", "config"]

[dependencies]
collections = "*"

[dev-dependencies]
testing = "*"

[build-system]
requires = ["mojo >=24.0"]
build-backend = "mojo.build"

[tool.test]
command = "mojo test"
coverage = true
parallel = true

[database]
host = "localhost"
port = 5432
user = "admin"
password = "secret"
pool.min = 5
pool.max = 20
pool.timeout = 30

[server]
host = "0.0.0.0"
port = 8080
workers = 4
timeout = 30
ssl.enabled = true
ssl.cert = "/path/to/cert"
ssl.key = "/path/to/key"

[logging]
level = "info"
format = "json"
outputs = ["stdout", "file"]
file.path = "/var/log/app.log"
file.rotate = "daily"
file.max_size = 10485760

[features]
authentication = ["jwt", "oauth"]
caching = ["redis", "memcached"]
monitoring = ["prometheus", "grafana"]
"""
    
    var iterations = 500
    var start = perf_counter()
    
    for i in range(iterations):
        var data = parse(toml_content)
    
    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)
    
    print("\nLarge document (8 tables, 40+ keys, arrays, nested):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_table_access() raises:
    """Benchmark table access overhead (copying)."""
    var toml_content = """
[database]
host = "localhost"
port = 5432

[database.primary]
host = "db1.example.com"
port = 5432

[database.replica]
host = "db2.example.com"
port = 5433
"""
    
    # Parse once
    var data = parse(toml_content)
    
    # Benchmark accessing tables repeatedly
    var iterations = 10000
    var start = perf_counter()
    
    for i in range(iterations):
        var db = data["database"].as_table()
        var primary = db["primary"].as_table()
        var host = primary["host"].as_string()
    
    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)
    
    print("\nTable access (nested as_table() calls):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per access")
    print("  Rate:", Int(Float64(iterations) / elapsed), "accesses/sec")


fn benchmark_pixi_toml() raises:
    """Benchmark parsing real pixi.toml if it exists."""
    try:
        var path = Path("pixi.toml")
        var content = path.read_text()
        
        var iterations = 100
        var start = perf_counter()
        
        for i in range(iterations):
            var data = parse(content)
        
        var elapsed = perf_counter() - start
        var avg_time = elapsed / Float64(iterations)
        
        print("\nReal-world pixi.toml:")
        print("  Total:", format_time(elapsed), "for", iterations, "iterations")
        print("  Average:", format_time(avg_time), "per parse")
        print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")
    except:
        print("\nReal-world pixi.toml: SKIPPED (file not found)")


fn main() raises:
    """Run all benchmarks."""
    print("=" * 60)
    print("mojo-toml Performance Benchmark")
    print("=" * 60)
    
    benchmark_simple_parse()
    benchmark_nested_tables()
    benchmark_arrays()
    benchmark_dotted_keys()
    benchmark_large_document()
    benchmark_table_access()
    benchmark_pixi_toml()
    
    print("\n" + "=" * 60)
    print("Benchmark Complete")
    print("=" * 60)
