#!/usr/bin/env python3
"""Test runner for mojo-toml test suite.

Automatically discovers and runs all test_*.mojo files in the tests/ directory.
"""

import subprocess
import sys
from pathlib import Path
from typing import List, Tuple


def discover_tests(tests_dir: Path) -> List[Path]:
    """Find all test_*.mojo files in tests directory."""
    return sorted(tests_dir.glob("test_*.mojo"))


def format_test_name(test_file: Path) -> str:
    """Convert test filename to readable name."""
    # Remove 'test_' prefix and '.mojo' suffix
    name = test_file.stem.replace("test_", "")
    # Convert underscores to spaces and title case
    return name.replace("_", " ").title()


def run_test(test_file: Path, current: int, total: int) -> Tuple[bool, str]:
    """Run a single test file and return (success, output)."""
    test_name = format_test_name(test_file)
    print(f"[{current}/{total}] {test_name}")

    try:
        result = subprocess.run(
            ["mojo", "-I", "src", str(test_file)],
            capture_output=True,
            text=True,
            timeout=30
        )

        # Print output (test framework shows pass/fail)
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)

        return result.returncode == 0, result.stdout

    except subprocess.TimeoutExpired:
        print(f"  ✗ TIMEOUT after 30s")
        return False, ""
    except Exception as e:
        print(f"  ✗ ERROR: {e}")
        return False, ""


def main():
    """Run all tests and report results."""
    # Find project root (where this script is located)
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    tests_dir = project_root / "tests"

    # Change to project root for consistent paths
    import os
    os.chdir(project_root)

    print("=== mojo-toml Test Suite ===")
    print()

    # Discover tests
    test_files = discover_tests(tests_dir)
    if not test_files:
        print("No test files found!")
        sys.exit(1)

    print(f"Found {len(test_files)} test suites")
    print()

    # Run tests
    failed = []
    for i, test_file in enumerate(test_files, 1):
        success, output = run_test(test_file, i, len(test_files))
        if not success:
            failed.append(test_file.name)

    # Summary
    print()
    print("=" * 50)
    if failed:
        print(f"✗ {len(failed)} test suite(s) FAILED:")
        for name in failed:
            print(f"  - {name}")
        sys.exit(1)
    else:
        print(f"✓ All {len(test_files)} test suites PASSED")
        sys.exit(0)


if __name__ == "__main__":
    main()
