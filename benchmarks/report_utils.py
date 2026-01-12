#!/usr/bin/env python3
"""Benchmark reporting utilities for generating markdown reports.

Based on pattern from max-learning/src/python/utils/benchmark_utils.py
"""

from pathlib import Path
from typing import Dict, List, Optional
from machine_info import get_system_info, get_timestamp


def format_benchmark_table(results: List[Dict], columns: List[str]) -> str:
    """Format benchmark results as markdown table.

    Args:
        results: List of result dictionaries
        columns: Column names to display (keys from result dicts)

    Returns:
        Markdown table string
    """
    if not results:
        return "No results available"

    # Header
    header = "| " + " | ".join(columns) + " |"
    separator = "|" + "|".join(["--------"] * len(columns)) + "|"

    # Rows
    rows = []
    for result in results:
        row_values = [str(result.get(col, "N/A")) for col in columns]
        rows.append("| " + " | ".join(row_values) + " |")

    return "\n".join([header, separator] + rows)


def generate_report(
    title: str,
    description: str,
    parse_results: Optional[List[Dict]] = None,
    write_results: Optional[List[Dict]] = None,
    notes: Optional[str] = None
) -> str:
    """Generate markdown benchmark report.

    Args:
        title: Report title
        description: Brief description
        parse_results: List of parsing benchmark results
        write_results: List of writing benchmark results
        notes: Optional additional notes

    Returns:
        Markdown formatted report
    """
    sys_info = get_system_info()
    timestamp = get_timestamp()

    # Build system info section
    sys_info_lines = [f"- **{key}**: {value}" for key, value in sys_info.items()]
    sys_info_str = "\n".join(sys_info_lines)

    # Build report
    lines = [
        f"# {title}",
        "",
        f"**Date**: {timestamp}",
        f"**Description**: {description}",
        "",
        "## System Information",
        "",
        sys_info_str,
        ""
    ]

    # Parse results
    if parse_results:
        lines.extend([
            "## Parsing Benchmarks",
            "",
            format_benchmark_table(
                parse_results,
                ["Test", "Avg Time", "Rate", "Iterations"]
            ),
            ""
        ])

    # Write results
    if write_results:
        lines.extend([
            "## Writing Benchmarks",
            "",
            format_benchmark_table(
                write_results,
                ["Test", "Avg Time", "Rate", "Iterations"]
            ),
            ""
        ])

    # Notes
    if notes:
        lines.extend([
            "## Notes",
            "",
            notes,
            ""
        ])

    return "\n".join(lines)


def save_report(content: str, output_dir: Path, filename: str) -> Path:
    """Save markdown report to file.

    Args:
        content: Markdown content
        output_dir: Directory to save in
        filename: Output filename (should end in .md)

    Returns:
        Path to saved file
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / filename

    with open(filepath, 'w') as f:
        f.write(content)

    return filepath
