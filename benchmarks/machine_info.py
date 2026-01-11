#!/usr/bin/env python3
"""Machine information utilities for benchmarks.

Collects system information for consistent benchmark reporting.
"""

import platform
import subprocess
from datetime import datetime
from typing import Dict


def get_gpu_info() -> str:
    """Get GPU information (macOS specific for now)."""
    try:
        if platform.system() == "Darwin":  # macOS
            result = subprocess.run(
                ["system_profiler", "SPDisplaysDataType"],
                capture_output=True,
                text=True,
                timeout=5
            )
            # Extract chipset info
            for line in result.stdout.split('\n'):
                if 'Chipset Model:' in line or 'Chip Model:' in line:
                    return line.split(':', 1)[1].strip()
        return "Unknown"
    except Exception:
        return "Unknown"


def get_cpu_info() -> str:
    """Get CPU information."""
    try:
        if platform.system() == "Darwin":  # macOS
            result = subprocess.run(
                ["sysctl", "-n", "machdep.cpu.brand_string"],
                capture_output=True,
                text=True,
                timeout=2
            )
            return result.stdout.strip()
        return platform.processor()
    except Exception:
        return platform.processor()


def get_ram_gb() -> float:
    """Get total RAM in GB."""
    try:
        if platform.system() == "Darwin":  # macOS
            result = subprocess.run(
                ["sysctl", "-n", "hw.memsize"],
                capture_output=True,
                text=True,
                timeout=2
            )
            bytes_ram = int(result.stdout.strip())
            return bytes_ram / (1024**3)
        return 0.0
    except Exception:
        return 0.0


def get_system_info() -> Dict[str, str]:
    """Collect system information for benchmark reports."""
    return {
        "OS": f"{platform.system()} {platform.release()}",
        "Machine": platform.machine(),
        "CPU": get_cpu_info(),
        "GPU": get_gpu_info(),
        "RAM": f"{get_ram_gb():.1f} GB",
        "Python": platform.python_version(),
    }


def format_system_info(info: Dict[str, str], indent: str = "  ") -> str:
    """Format system info for console output."""
    lines = []
    for key, value in info.items():
        lines.append(f"{indent}{key}: {value}")
    return "\n".join(lines)


def get_timestamp() -> str:
    """Get current timestamp for benchmark reports."""
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')
