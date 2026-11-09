"""Check that the docs index and AGENTS.md list every project guide."""

from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
INDEX = DOCS / "README.md"
AGENTS = ROOT / "AGENTS.md"


def linked_docs(source: Path, errors: list[str]) -> set[Path]:
    content = source.read_text(encoding="utf-8")
    targets = set()

    for link in re.findall(r"\[[^\]]+\]\(([^)]+)\)", content):
        parsed = urlsplit(link.strip())
        if parsed.scheme or parsed.netloc or not parsed.path:
            continue
        target = (source.parent / unquote(parsed.path)).resolve()
        if not target.is_file():
            errors.append(f"{source.relative_to(ROOT)} links to missing file: {link}")
        elif target.is_relative_to(DOCS.resolve()) and target != INDEX.resolve():
            targets.add(target)

    return targets


def main() -> int:
    errors = []
    index_docs = linked_docs(INDEX, errors)
    agents_docs = linked_docs(AGENTS, errors)
    expected = {
        path.resolve()
        for path in DOCS.rglob("*.md")
        if path.resolve() != INDEX.resolve()
    }

    for source, found in ((INDEX, index_docs), (AGENTS, agents_docs)):
        for path in sorted(expected - found):
            errors.append(f"{source.relative_to(ROOT)} misses {path.relative_to(ROOT)}")

    if index_docs != agents_docs:
        errors.append("docs/README.md and AGENTS.md list different project docs")

    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1

    print(f"AGENTS.md and docs/README.md list all {len(expected)} project docs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
