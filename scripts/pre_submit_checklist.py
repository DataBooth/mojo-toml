#!/usr/bin/env python3
"""Pre-submission validation checklist (Python version).

This script orchestrates all validation steps required before submitting to
modular-community. It replaces the Bash-heavy logic with a more robust Python
implementation while preserving the existing checks:

1. Run full test suite
2. Validate recipe schema
3. Build package with rattler-build and verify artefacts
4. Verify git tag exists and matches recipe version
5. Verify package installs and files are present
"""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, List


# Colours for output
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
BOLD = "\033[1m"
NC = "\033[0m"  # No colour


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_DIR = PROJECT_ROOT / "scripts"
RECIPE_FILE = PROJECT_ROOT / "recipe.yaml"
OUTPUT_DIR = PROJECT_ROOT / "output"


@dataclass
class CheckResult:
    name: str
    success: bool
    message: str


def info(msg: str) -> None:
    print(f"{BLUE}→ {msg}{NC}")


def success(msg: str) -> None:
    print(f"{GREEN}✓ {msg}{NC}")


def error(msg: str) -> None:
    print(f"{RED}✗ {msg}{NC}", file=sys.stderr)


def section(title: str) -> None:
    print()
    line = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print(f"{BOLD}{BLUE}{line}{NC}")
    print(f"{BOLD}{BLUE}{title}{NC}")
    print(f"{BOLD}{BLUE}{line}{NC}")


def run_command(cmd: List[str], *, check_name: str) -> subprocess.CompletedProcess:
    """Run a command, returning the CompletedProcess without raising.

    Stdout/stderr are inherited so the user sees streaming output.
    Any OS-level failure (e.g. command not found) is turned into a
    synthetic non-zero return code for the caller to handle.
    """

    try:
        return subprocess.run(cmd, cwd=PROJECT_ROOT, check=False)
    except FileNotFoundError:
        error(f"Required command not found while running '{' '.join(cmd)}'")
        # Use 127 (command not found) by convention
        cp = subprocess.CompletedProcess(cmd, returncode=127)
        return cp


def get_recipe_version(path: Path) -> str | None:
    """Extract the concrete numeric version from recipe.yaml.

    The file contains multiple "version" fields (context.version,
    package.version template). We want the numeric value from the
    context block, e.g. "0.5.1".
    """

    if not path.is_file():
        return None

    in_context = False
    try:
        with path.open("r", encoding="utf-8") as f:
            for raw_line in f:
                line = raw_line.rstrip("\n")
                if not line.strip():
                    continue

                # Top-level key
                if not line.startswith(" "):
                    in_context = line.strip().startswith("context:")
                    continue

                if in_context:
                    stripped = line.strip()
                    if stripped.startswith("version:"):
                        _, value = stripped.split(":", 1)
                        return value.strip().strip("'\"")
    except OSError as exc:
        error(f"Failed to read recipe file: {exc}")
        return None

    return None


def check_tests() -> CheckResult:
    section("CHECK 1: Running full test suite")
    cp = run_command(["pixi", "run", "test-all"], check_name="Full test suite")
    if cp.returncode == 0:
        success("All tests pass")
        return CheckResult("Full test suite", True, "All tests pass")
    error("Tests failed")
    return CheckResult("Full test suite", False, "Tests failed")


def check_recipe_validation() -> CheckResult:
    section("CHECK 2: Validating recipe schema")

    if not RECIPE_FILE.is_file():
        msg = f"Recipe file not found: {RECIPE_FILE}"
        error(msg)
        return CheckResult("Recipe schema", False, msg)

    cp = run_command(["bash", str(SCRIPT_DIR / "validate-recipe.sh"), str(RECIPE_FILE)],
                     check_name="Recipe validation")
    if cp.returncode == 0:
        success("Recipe schema is valid")
        return CheckResult("Recipe schema", True, "Recipe schema is valid")

    msg = "Recipe validation failed"
    error(msg)
    return CheckResult("Recipe schema", False, msg)


def check_build_and_artifacts() -> List[CheckResult]:
    section("CHECK 3: Building package with rattler-build")

    results: List[CheckResult] = []

    cp = run_command(["bash", str(SCRIPT_DIR / "build-recipe.sh")],
                     check_name="Build recipe")
    if cp.returncode == 0:
        success("Package builds successfully")
        results.append(CheckResult("Build package", True, "Package builds successfully"))
    else:
        msg = "Package build failed"
        error(msg)
        results.append(CheckResult("Build package", False, msg))
        # If the build failed, artefact checks will only be noise
        return results

    # Verify artefacts exist
    package_files: List[Path] = []
    if OUTPUT_DIR.is_dir():
        for pattern in ("*.conda", "*.tar.bz2"):
            package_files.extend(OUTPUT_DIR.rglob(pattern))

    if package_files:
        msg = f"Package artefacts created: {len(package_files)} file(s)"
        success(msg)
        results.append(CheckResult("Package artefacts", True, msg))
    else:
        msg = "No package artefacts found"
        error(msg)
        results.append(CheckResult("Package artefacts", False, msg))

    return results


def check_git_tag() -> List[CheckResult]:
    section("CHECK 4: Verifying git tag")

    results: List[CheckResult] = []

    version = get_recipe_version(RECIPE_FILE)
    if not version:
        msg = "Could not extract version from recipe.yaml"
        error(msg)
        results.append(CheckResult("Git tag exists", False, msg))
        return results

    info(f"Recipe version: {version}")
    tag = f"v{version}"

    # Check if tag exists
    cp_tags = subprocess.run([
        "git",
        "tag",
        "--list",
        tag,
    ], cwd=PROJECT_ROOT, check=False, capture_output=True, text=True)

    if cp_tags.returncode == 0 and cp_tags.stdout.strip():
        success(f"Git tag {tag} exists")
        results.append(CheckResult("Git tag exists", True, f"Git tag {tag} exists"))
    else:
        msg = f"Git tag {tag} does not exist"
        error(msg)
        info(f"Create tag with: git tag -a {tag} -m 'Release {tag}'")
        results.append(CheckResult("Git tag exists", False, msg))
        return results

    # Check if tag points to HEAD
    cp_tag_commit = subprocess.run(["git", "rev-list", "-n", "1", tag],
                                   cwd=PROJECT_ROOT, check=False, capture_output=True, text=True)
    cp_head_commit = subprocess.run(["git", "rev-parse", "HEAD"],
                                    cwd=PROJECT_ROOT, check=False, capture_output=True, text=True)

    tag_commit = cp_tag_commit.stdout.strip()
    head_commit = cp_head_commit.stdout.strip()

    if tag_commit and head_commit and tag_commit == head_commit:
        success(f"Tag {tag} points to HEAD")
        results.append(CheckResult("Git tag points to HEAD", True, f"Tag {tag} points to HEAD"))
    else:
        msg = (
            f"Tag {tag} does not point to HEAD "
            f"(tag: {tag_commit[:8] if tag_commit else 'unknown'}, "
            f"HEAD: {head_commit[:8] if head_commit else 'unknown'})"
        )
        error(msg)
        info(f"To move the tag to HEAD: git tag -f {tag} HEAD && git push --force origin {tag}")
        results.append(CheckResult("Git tag points to HEAD", False, msg))

    return results


def check_package_install() -> List[CheckResult]:
    section("CHECK 5: Testing package installation")

    results: List[CheckResult] = []

    with tempfile.TemporaryDirectory() as tmpdir:
        test_project = Path(tmpdir) / "test-install"
        info(f"Creating test environment at {test_project}")

        # Initialise pixi project
        cp_init = run_command(["pixi", "init", str(test_project)],
                              check_name="pixi init test project")
        if cp_init.returncode != 0:
            msg = "Failed to create test environment"
            error(msg)
            results.append(CheckResult("Package installation", False, msg))
            return results

        # Configure channels for the test project so mojo-toml can be resolved
        manifest_path = test_project / "pixi.toml"
        cmd_channels = [
            "pixi",
            "project",
            "--manifest-path",
            str(manifest_path),
            "channel",
            "add",
            f"file://{OUTPUT_DIR}",
            "conda-forge",
            "https://conda.modular.com/max",
            "https://prefix.dev/modular-community",
        ]
        cp_channels = run_command(
            cmd_channels,
            check_name="pixi project channel add local and remote channels for test project",
        )
        if cp_channels.returncode != 0:
            msg = "Failed to configure channels for test project"
            error(msg)
            results.append(CheckResult("Package installation", False, msg))
            return results

        # Try to add the local package using the configured channels
        cmd_add = [
            "pixi",
            "add",
            "--manifest-path",
            str(manifest_path),
            "mojo-toml",
        ]
        cp_add = run_command(cmd_add, check_name="pixi add mojo-toml from configured channels")
        if cp_add.returncode != 0:
            msg = "Package installation failed"
            error(msg)
            results.append(CheckResult("Package installation", False, msg))
            return results

        success("Package installs successfully")
        results.append(CheckResult("Package installation", True, "Package installs successfully"))

        # Verify files are present
        # The recipe installs files under $PREFIX/lib/mojo/toml
        installed_root = (
            test_project
            / ".pixi"
            / "envs"
            / "default"
            / "lib"
            / "mojo"
        )
        installed_toml = installed_root / "toml"

        if installed_toml.is_dir():
            msg = "Package files installed correctly (lib/mojo/toml)"
            success(msg)
            results.append(CheckResult("Package files present", True, msg))
        else:
            msg = f"Package files not found in environment (expected {installed_toml})"
            error(msg)
            results.append(CheckResult("Package files present", False, msg))

    return results


def print_header() -> None:
    print()
    print(f"{BOLD}{GREEN}╔══════════════════════════════════════════════════════════════╗{NC}")
    print(f"{BOLD}{GREEN}║         Pre-Submission Validation Checklist                  ║{NC}")
    print(f"{BOLD}{GREEN}╚══════════════════════════════════════════════════════════════╝{NC}")
    print()


def print_summary(results: List[CheckResult], recipe_version: str | None) -> int:
    section("SUMMARY")
    print()

    passed = sum(1 for r in results if r.success)
    failed = sum(1 for r in results if not r.success)

    if failed == 0:
        print(f"{BOLD}{GREEN}╔══════════════════════════════════════════════════════════════╗{NC}")
        print(
            f"{BOLD}{GREEN}║  ✓ ALL CHECKS PASSED ({passed}/{passed + failed})"
            f"                                    ║{NC}"
        )
        print(f"{BOLD}{GREEN}╚══════════════════════════════════════════════════════════════╝{NC}")
        print()
        print(f"{GREEN}✓ Package is ready for submission to modular-community{NC}")
        print()
        if recipe_version:
            tag = f"v{recipe_version}"
        else:
            tag = "<version>"
        info("Next steps:")
        print(f"  1. Push tag: git push origin {tag}")
        print("  2. Update recipe in modular-community PR")
        print("  3. Push updated recipe to trigger CI")
        print()
        return 0

    print(f"{BOLD}{RED}╔══════════════════════════════════════════════════════════════╗{NC}")
    print(
        f"{BOLD}{RED}║  ✗ CHECKS FAILED ({failed}/{passed + failed})"
        f"                                       ║{NC}"
    )
    print(f"{BOLD}{RED}╚══════════════════════════════════════════════════════════════╝{NC}")
    print()
    print(f"{RED}Failed checks:{NC}")
    for r in results:
        if not r.success:
            print(f"{RED}  - {r.name}: {r.message}{NC}")
    print()
    print(f"{YELLOW}⚠ Fix issues before submitting to modular-community{NC}")
    print()
    return 1


def main() -> int:
    os.chdir(PROJECT_ROOT)
    print_header()

    all_results: List[CheckResult] = []

    # Run checks sequentially to preserve readable output ordering
    all_results.append(check_tests())
    all_results.append(check_recipe_validation())
    all_results.extend(check_build_and_artifacts())
    all_results.extend(check_git_tag())
    all_results.extend(check_package_install())

    recipe_version = get_recipe_version(RECIPE_FILE)
    return print_summary(all_results, recipe_version)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print()
        error("Interrupted by user")
        sys.exit(1)
