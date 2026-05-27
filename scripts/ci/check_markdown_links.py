#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse


ROOT = Path(__file__).resolve().parents[2]
INLINE_LINK = re.compile(r"(?<!!)\[[^\]]+\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
REFERENCE_LINK = re.compile(r"^\s*\[[^\]]+\]:\s+(\S+)", re.MULTILINE)
SKIP_SCHEMES = {"http", "https", "mailto", "tel"}


def markdown_files() -> list[Path]:
    return [ROOT / path for path in subprocess_ls_files() if path.suffix.lower() == ".md"]


def subprocess_ls_files() -> list[Path]:
    import subprocess

    result = subprocess.run(
        ["git", "ls-files", "-z", "*.md"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [Path(item.decode("utf-8")) for item in result.stdout.split(b"\0") if item]


def normalize_target(source: Path, raw_url: str) -> Path | None:
    parsed = urlparse(raw_url.strip("<>"))
    if parsed.scheme in SKIP_SCHEMES:
        return None
    if parsed.scheme:
        return None
    if parsed.path == "":
        return source
    target_text = unquote(parsed.path)
    target = (source.parent / target_text).resolve()
    try:
        target.relative_to(ROOT)
    except ValueError:
        return target
    return target


def main() -> int:
    errors: list[str] = []
    for path in markdown_files():
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(ROOT).as_posix()
        urls = INLINE_LINK.findall(text) + REFERENCE_LINK.findall(text)
        for url in urls:
            target = normalize_target(path, url)
            if target is None:
                continue
            if not target.exists():
                errors.append(f"{rel}: broken local link: {url}")

    if errors:
        print("Markdown local link check failed:")
        for error in errors:
            print(f"  {error}")
        return 1
    print("Markdown local link check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
