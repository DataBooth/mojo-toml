#!/usr/bin/env python3
"""Wrapper to run mojo-toml benchmark and generate markdown report.

This script runs the Mojo benchmark, parses its output, and generates
a markdown report with system information.
"""

import re
import subprocess
import sys
from pathlib import Path

# Import local utilities
sys.path.insert(0, str(Path(__file__).parent))
from machine_info import get_system_info, format_system_info, get_timestamp
from report_utils import generate_report, save_report


def parse_benchmark_output(output: str) -> list:
    """Parse mojo benchmark output into structured results.
    
    Args:
        output: Console output from benchmark
    
    Returns:
        List of result dictionaries
    """
    results = []
    lines = output.split('\n')
    
    current_test = None
    for line in lines:
        # Match test name lines (e.g., "Simple parse (5 keys):")
        if line and not line.startswith(' ') and ':' in line and not line.startswith('='):
            current_test = line.rstrip(':')
        
        # Match average time lines
        elif 'Average:' in line and current_test:
            # Extract time (e.g., "  Average: 24 μs per parse")
            time_match = re.search(r'(\d+\s*(?:μs|ms|s))', line)
            avg_time = time_match.group(1) if time_match else "N/A"
            
            # Look for rate in next lines
            rate = "N/A"
            iterations = "N/A"
            
            results.append({
                "Test": current_test,
                "Avg Time": avg_time,
                "Rate": rate,
                "Iterations": iterations
            })
        
        # Match rate lines
        elif 'Rate:' in line and results:
            rate_match = re.search(r'Rate:\s*(\d+)', line)
            if rate_match:
                rate_val = int(rate_match.group(1))
                if rate_val >= 1000:
                    results[-1]["Rate"] = f"{rate_val / 1000:.1f}K/sec"
                else:
                    results[-1]["Rate"] = f"{rate_val}/sec"
            
            # Also extract iterations
            iter_match = re.search(r'for\s+(\d+)\s+iterations', line)
            if not iter_match:
                # Try previous line
                idx = lines.index(line)
                if idx > 0:
                    iter_match = re.search(r'for\s+(\d+)\s+iterations', lines[idx-1])
            
            if iter_match:
                results[-1]["Iterations"] = iter_match.group(1)
    
    return results


def main():
    """Run mojo benchmark and generate report."""
    print("=" * 70)
    print("mojo-toml Performance Benchmark")
    print("=" * 70)
    
    # Display system info
    print("\nSystem Information:")
    sys_info = get_system_info()
    print(format_system_info(sys_info))
    print(f"  Timestamp: {get_timestamp()}")
    
    # Add Mojo version
    try:
        mojo_result = subprocess.run(
            ["mojo", "--version"],
            capture_output=True,
            text=True,
            timeout=5
        )
        mojo_version = mojo_result.stdout.strip() or mojo_result.stderr.strip()
        print(f"  Mojo: {mojo_version}")
        sys_info["Mojo"] = mojo_version
    except:
        sys_info["Mojo"] = "Unknown"
    
    print("\n" + "=" * 70)
    print("Running benchmarks...")
    print("=" * 70)
    
    # Run mojo benchmark
    try:
        result = subprocess.run(
            ["mojo", "-I", "src", "benchmarks/benchmark_parser.mojo"],
            capture_output=True,
            text=True,
            cwd=Path(__file__).parent.parent,
            timeout=60
        )
        
        # Print the output
        print(result.stdout)
        
        if result.returncode != 0:
            print(f"Error running benchmark: {result.stderr}", file=sys.stderr)
            sys.exit(1)
        
        # Parse results
        results = parse_benchmark_output(result.stdout)
        
        # Generate markdown report
        report = generate_report(
            title="mojo-toml Performance Benchmark",
            description="Performance measurements for mojo-toml v0.5.0 parser. Tests include simple documents, nested tables, arrays, dotted keys, and real-world files.",
            parse_results=results,
            write_results=None,
            notes="Run `pixi run benchmark-python` to see Python baseline performance for comparison."
        )
        
        # Save report
        report_dir = Path(__file__).parent / "reports"
        report_path = save_report(report, report_dir, "mojo_toml.md")
        
        print(f"\nMarkdown report saved to: {report_path}")
        
    except subprocess.TimeoutExpired:
        print("Error: Benchmark timed out", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
