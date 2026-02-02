#!/usr/bin/env python3
"""Example runner for Mojo libraries.

Automatically discovers and runs all *.mojo files in the examples/ directory.
"""

import os
import subprocess
import sys
from pathlib import Path
from typing import List, Tuple


def get_project_root() -> Path:
    """Return the project root directory (parent of this script)."""
    return Path(__file__).resolve().parents[1]


def discover_examples(project_root: Path) -> List[Path]:
    """Return the list of example files to run in order.

    Looks for *.mojo files in the examples/ directory. If the directory does
    not exist or contains no Mojo files, returns an empty list.
    """

    examples_dir = project_root / "examples"
    if not examples_dir.is_dir():
        return []

    return sorted(examples_dir.glob("*.mojo"))


def format_example_name(example_file: Path) -> str:
    """Convert example filename to a readable name."""
    name = example_file.stem
    return name.replace("_", " ").title()


def run_example(example_file: Path, current: int, total: int) -> Tuple[bool, int]:
    """Run a single example and return (success, returncode)."""
    example_name = format_example_name(example_file)
    print(f"[{current}/{total}] {example_name}")
    print("-" * 60)

    project_root = get_project_root()

    try:
        result = subprocess.run(
            ["mojo", "-I", "src", str(example_file)],
            cwd=str(project_root),
            check=False,
        )
        print()
        return result.returncode == 0, result.returncode
    except KeyboardInterrupt:
        print("\nInterrupted by user")
        raise
    except Exception as e:  # pragma: no cover - defensive
        print(f"  ✗ ERROR: {e}")
        print()
        return False, 1


def main() -> int:
    project_root = get_project_root()
    os.chdir(project_root)

    project_name = project_root.name
    print(f"=== {project_name} Examples ===")
    print()

    example_files = discover_examples(project_root)
    if not example_files:
        print("No example files found in examples/ directory")
        return 1

    print(f"Found {len(example_files)} example(s)")
    print()

    failed: List[str] = []
    for i, example_file in enumerate(example_files, 1):
        success, _ = run_example(example_file, i, len(example_files))
        if not success:
            failed.append(example_file.name)

    print("=" * 60)
    if failed:
        print(f"✗ {len(failed)} example(s) FAILED:")
        for name in failed:
            print(f"  - {name}")
        return 1

    print(f"✓ All {len(example_files)} examples ran successfully")
    return 0


if __name__ == "__main__":
    sys.exit(main())
