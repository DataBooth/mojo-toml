#!/usr/bin/env python3
"""Comparative benchmarks: mojo-toml vs Python tomllib/tomli_w.

Compares parsing and writing performance between mojo-toml and Python's
standard library TOML implementations.

Run with: pixi run benchmark-python
"""

import sys
import time
import tomllib  # Python 3.11+ standard library (read-only)
import tomli_w  # Write support
from pathlib import Path

# Import benchmark utilities
sys.path.insert(0, str(Path(__file__).parent))
from machine_info import get_system_info, format_system_info, get_timestamp
from report_utils import generate_report, save_report


# Test documents
SIMPLE_TOML = """title = "TOML Benchmark"
version = "1.0.0"
enabled = true
count = 42
pi = 3.14159
"""

NESTED_TABLES = """[database]
host = "localhost"
port = 5432

[database.primary]
host = "db1.example.com"
port = 5432

[server]
host = "0.0.0.0"
port = 8080
"""

ARRAY_OF_TABLES = """[[products]]
name = "Hammer"
sku = 738594937

[[products]]
name = "Nail"
sku = 284758393
"""

ALT_NUMBER_BASES = """hex = 0xDEADBEEF
octal = 0o755
binary = 0b11010110
"""


def benchmark_python_parse(toml_content: str, iterations: int = 1000) -> tuple[float, int]:
    """Benchmark Python's tomllib parsing. Returns (elapsed_time, iterations)."""
    start = time.perf_counter()
    for _ in range(iterations):
        _ = tomllib.loads(toml_content)
    elapsed = time.perf_counter() - start
    return elapsed, iterations


def benchmark_python_write(data: dict, iterations: int = 500) -> tuple[float, int]:
    """Benchmark Python's tomli_w writing. Returns (elapsed_time, iterations)."""
    start = time.perf_counter()
    for _ in range(iterations):
        _ = tomli_w.dumps(data)
    elapsed = time.perf_counter() - start
    return elapsed, iterations


def format_time(seconds: float) -> str:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return f"{seconds * 1_000_000:.0f} μs"
    elif seconds < 1.0:
        return f"{seconds * 1_000:.1f} ms"
    else:
        return f"{seconds:.2f} s"


def format_rate(rate: float) -> str:
    """Format rate with thousands separator."""
    if rate >= 1_000_000:
        return f"{rate / 1_000_000:.2f}M/sec"
    elif rate >= 1_000:
        return f"{rate / 1_000:.1f}K/sec"
    else:
        return f"{rate:.0f}/sec"


def run_parse_comparison(name: str, toml_content: str, iterations: int = 1000) -> dict:
    """Run and display Python parsing benchmark. Returns result dict."""
    print(f"\n{name}:")

    py_time, py_iters = benchmark_python_parse(toml_content, iterations)
    py_rate = py_iters / py_time
    py_avg = py_time / py_iters

    print(f"  Python (tomllib):  {format_time(py_avg)} per parse  |  {format_rate(py_rate)}")

    return {
        "Test": name,
        "Avg Time": format_time(py_avg),
        "Rate": format_rate(py_rate),
        "Iterations": py_iters
    }


def run_write_comparison(name: str, data: dict, iterations: int = 500) -> dict:
    """Run and display Python writing benchmark. Returns result dict."""
    print(f"\n{name}:")

    py_time, py_iters = benchmark_python_write(data, iterations)
    py_rate = py_iters / py_time
    py_avg = py_time / py_iters

    print(f"  Python (tomli_w):  {format_time(py_avg)} per write  |  {format_rate(py_rate)}")

    return {
        "Test": name,
        "Avg Time": format_time(py_avg),
        "Rate": format_rate(py_rate),
        "Iterations": py_iters
    }


def main():
    """Run all comparison benchmarks."""
    print("=" * 70)
    print("Python TOML Baseline Benchmarks (tomllib + tomli_w)")
    print("=" * 70)

    # Display system info
    print("\nSystem Information:")
    sys_info = get_system_info()
    print(format_system_info(sys_info))
    print(f"  Timestamp: {get_timestamp()}")

    print("\nThese establish baseline performance for comparison with mojo-toml.")
    print("Run 'pixi run benchmark-mojo' to see mojo-toml performance.")

    # Collect parse results
    print("\n\nParsing Benchmarks (tomllib):")
    print("=" * 70)

    parse_results = []
    parse_results.append(run_parse_comparison("Simple document (5 keys)", SIMPLE_TOML, 1000))
    parse_results.append(run_parse_comparison("Nested tables (3 tables, 6 keys)", NESTED_TABLES, 1000))
    parse_results.append(run_parse_comparison("Array of tables (2 products)", ARRAY_OF_TABLES, 1000))
    parse_results.append(run_parse_comparison("Alternative number bases (3 numbers)", ALT_NUMBER_BASES, 1000))

    # Collect write results
    print("\n\nWriting Benchmarks (tomli_w):")
    print("=" * 70)

    write_results = []
    simple_data = {
        "title": "TOML Benchmark",
        "version": "1.0.0",
        "enabled": True,
        "count": 42,
        "pi": 3.14159
    }
    write_results.append(run_write_comparison("Simple document (5 keys)", simple_data, 500))

    nested_data = {
        "database": {
            "host": "localhost",
            "port": 5432,
            "primary": {
                "host": "db1.example.com",
                "port": 5432
            }
        },
        "server": {
            "host": "0.0.0.0",
            "port": 8080
        }
    }
    write_results.append(run_write_comparison("Nested tables (3 tables, 6 keys)", nested_data, 500))

    print("\n" + "=" * 70)
    print("Benchmark Complete")
    print("=" * 70)

    # Generate and save markdown report
    report = generate_report(
        title="Python TOML Baseline Benchmarks",
        description="Baseline performance measurements for Python's tomllib (parsing) and tomli_w (writing). These establish comparison baselines for mojo-toml.",
        parse_results=parse_results,
        write_results=write_results,
        notes="These benchmarks use Python 3.11+ stdlib `tomllib` for parsing and `tomli_w` for writing. Run `pixi run benchmark-mojo` to see mojo-toml performance."
    )

    report_dir = Path(__file__).parent / "reports"
    report_path = save_report(report, report_dir, "python_baseline.md")

    print(f"\nMarkdown report saved to: {report_path}")
    print("\nNote: These are Python baseline numbers.")
    print("For mojo-toml performance, run: pixi run benchmark-mojo")


if __name__ == "__main__":
    main()
