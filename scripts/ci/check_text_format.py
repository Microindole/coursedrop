#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TEXT_SUFFIXES = {
    ".css",
    ".ets",
    ".gitignore",
    ".html",
    ".java",
    ".js",
    ".json",
    ".json5",
    ".md",
    ".properties",
    ".ps1",
    ".sh",
    ".ts",
    ".txt",
    ".xml",
    ".yaml",
    ".yml",
}
TRAILING_WHITESPACE_ALLOWED = {".md"}


def tracked_files(paths: list[str]) -> list[Path]:
    command = ["git", "ls-files", "-z"]
    if paths:
        command.extend(["--", *paths])
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [ROOT / item.decode("utf-8") for item in result.stdout.split(b"\0") if item]


def is_text_file(path: Path) -> bool:
    return path.suffix in TEXT_SUFFIXES or path.name in TEXT_SUFFIXES


def main() -> int:
    errors: list[str] = []
    for path in tracked_files(sys.argv[1:]):
        rel = path.relative_to(ROOT).as_posix()
        if not is_text_file(path):
            continue
        data = path.read_bytes()
        if b"\0" in data:
            continue
        if data and not data.endswith(b"\n"):
            errors.append(f"{rel}: missing final newline")
        if b"\r\n" in data or b"\r" in data:
            errors.append(f"{rel}: CRLF line ending; use LF")
        if path.suffix not in TRAILING_WHITESPACE_ALLOWED:
            for line_number, line in enumerate(data.splitlines(), start=1):
                if line.endswith((b" ", b"\t")):
                    errors.append(f"{rel}:{line_number}: trailing whitespace")
                    break

    if errors:
        print("Text format check failed:")
        for error in errors:
            print(f"  {error}")
        print("\nFollow .editorconfig: LF line endings, final newline, no trailing whitespace.")
        return 1
    print("Text format check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
