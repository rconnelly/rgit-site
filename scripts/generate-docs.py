#!/usr/bin/env python3
"""Turn rabun-git/doc into Zola pages under content/docs/.

The user guide in the rabun-git checkout is the source of truth. Re-run this
after that guide changes. Homepage copy stays hand-written.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

SITE = Path(__file__).resolve().parents[1]
SOURCE = Path(os.environ.get("RABUN_GIT_DIR", SITE.parent / "rabun-git"))
DOC = SOURCE / "doc"
OUT = SITE / "content" / "docs"
REPO = "https://github.com/Burton-Workspaces/rabun-git/blob/master/"

# Guide order from doc/README.md. Operator pages follow the walkthrough.
PAGES = [
    ("what-it-is.md", 1),
    ("install.md", 2),
    ("start-the-forge.md", 3),
    ("remote-repository.md", 4),
    ("users-and-roles.md", 5),
    ("everyday-git.md", 6),
    ("merge-requests.md", 7),
    ("ci-workflows.md", 8),
    ("commands.md", 9),
    ("compared-to-github.md", 10),
    ("architecture.md", 20),
    ("deploy-ubuntu.md", 21),
]

LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")
FENCE = re.compile(r"(```.*?```)", re.DOTALL)


def toml_str(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def rewrite_target(url: str) -> str:
    if url.startswith(("http://", "https://", "mailto:", "#")):
        return url
    path, sep, frag = url.partition("#")
    path = path.removeprefix("./")
    if path.startswith("../"):
        return REPO + path[3:] + (("#" + frag) if sep else "")
    path = path.removeprefix("doc/")
    if path in ("README.md", "readme.md"):
        dest = "/docs/"
    elif path.endswith(".md"):
        dest = f"/docs/{path[:-3]}/"
    else:
        return url
    if sep:
        dest += "#" + frag
    return dest


def rewrite_links(markdown: str) -> str:
    def repl(match: re.Match[str]) -> str:
        label, url = match.group(1), match.group(2)
        return f"[{label}]({rewrite_target(url)})"

    parts = FENCE.split(markdown)
    return "".join(part if part.startswith("```") else LINK.sub(repl, part) for part in parts)


def strip_first_heading(markdown: str) -> tuple[str, str]:
    title = ""
    lines = markdown.splitlines()
    start = 0
    while start < len(lines) and not lines[start].strip():
        start += 1
    if start < len(lines) and lines[start].startswith("# "):
        title = lines[start][2:].strip()
        start += 1
        if start < len(lines) and not lines[start].strip():
            start += 1
    body = "\n".join(lines[start:]).strip() + "\n"
    return title, body


def description_from(body: str, fallback: str) -> str:
    chunk: list[str] = []
    for line in body.splitlines():
        stripped = line.strip()
        if not stripped:
            if chunk:
                break
            continue
        if stripped.startswith(("#", "|", "```", "- ", "* ", ">")):
            if chunk:
                break
            continue
        chunk.append(stripped)
    text = " ".join(chunk)
    text = LINK.sub(r"\1", text)
    text = text.replace("**", "").replace("`", "")
    text = re.sub(r"\s+", " ", text).strip()
    sentence = re.match(r"^(.+?[.!?])(?:\s|$)", text)
    if sentence and len(sentence.group(1)) <= 180:
        return sentence.group(1)
    if len(text) > 180:
        text = text[:177].rsplit(" ", 1)[0].rstrip(".;,") + "…"
    return text or fallback


def page_front(title: str, description: str, weight: int, source: str) -> str:
    return (
        "+++\n"
        f"title = {toml_str(title)}\n"
        f"description = {toml_str(description)}\n"
        f"weight = {weight}\n"
        "\n"
        "[extra]\n"
        "generated = true\n"
        f"source = {toml_str(source)}\n"
        "+++\n\n"
    )


def write_page(name: str, weight: int) -> None:
    raw = (DOC / name).read_text(encoding="utf-8")
    title, body = strip_first_heading(raw)
    if not title:
        title = name.removesuffix(".md").replace("-", " ")
    body = rewrite_links(body)
    description = description_from(body, title)
    text = page_front(title, description, weight, f"doc/{name}") + body
    (OUT / name).write_text(text, encoding="utf-8")


def write_index() -> None:
    raw = (DOC / "README.md").read_text(encoding="utf-8")
    title, body = strip_first_heading(raw)
    body = rewrite_links(body)
    description = description_from(
        body, "User guide for the Rabun Git forge."
    )
    front = (
        "+++\n"
        f"title = {toml_str(title or 'User guide')}\n"
        f"description = {toml_str(description)}\n"
        'sort_by = "weight"\n'
        'template = "docs.html"\n'
        'page_template = "doc-page.html"\n'
        "\n"
        "[extra]\n"
        "generated = true\n"
        'source = "doc/README.md"\n'
        "+++\n\n"
    )
    (OUT / "_index.md").write_text(front + body, encoding="utf-8")


def main() -> int:
    if not DOC.is_dir():
        print(f"rabun-git docs not found: {DOC}", file=sys.stderr)
        return 1
    OUT.mkdir(parents=True, exist_ok=True)
    missing = [name for name, _ in PAGES if not (DOC / name).is_file()]
    if missing:
        print("missing guide pages: " + ", ".join(missing), file=sys.stderr)
        return 1
    for name, weight in PAGES:
        write_page(name, weight)
    write_index()
    stale = OUT / "getting-started.md"
    if stale.is_file():
        stale.unlink()
    print(f"wrote {len(PAGES)} guide pages and content/docs/_index.md from {DOC}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
