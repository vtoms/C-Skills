"""Static checks for .claude/skills/*/SKILL.md frontmatter.

Catches the failure modes seen in the wild (e.g. pstack#4: names with spaces
break invocation outside Cursor).
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent / ".claude" / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
WHEN_RE = re.compile(r"\buse (when|for|at|before|after)\b", re.IGNORECASE)
# Community audits of pstack flagged these as unsafe in shared skills.
UNSAFE_RE = re.compile(r"sudo |curl [^\n|]*\| *(ba)?sh|push --force|push -f\b|--force-with-lease|gh pr merge|@latest", re.IGNORECASE)
RESERVED = {"code-review", "simplify", "init", "review", "security-review", "loop", "run"}


def parse_frontmatter(text):
    if not text.startswith("---\n"):
        return None, "missing opening ---"
    end = text.find("\n---", 4)
    if end == -1:
        return None, "missing closing ---"
    fields = {}
    for line in text[4:end].splitlines():
        if ":" in line and not line.startswith(" "):
            key, value = line.split(":", 1)
            fields[key.strip()] = value.strip().strip('"')
    return fields, text[end + 4:]


def main():
    errors = []
    dirs = sorted(p for p in ROOT.iterdir() if p.is_dir())
    for d in dirs:
        f = d / "SKILL.md"
        if not f.exists():
            errors.append(f"{d.name}: no SKILL.md")
            continue
        fm, body = parse_frontmatter(f.read_text())
        if fm is None:
            errors.append(f"{d.name}: {body}")
            continue
        name, desc = fm.get("name", ""), fm.get("description", "")
        if name != d.name:
            errors.append(f"{d.name}: name '{name}' does not match directory")
        if not NAME_RE.match(name) or len(name) > 64:
            errors.append(f"{d.name}: name must be kebab-case, <=64 chars")
        if name in RESERVED:
            errors.append(f"{d.name}: name clashes with a built-in command")
        if not 40 <= len(desc) <= 1024:
            errors.append(f"{d.name}: description length {len(desc)} not in 40..1024")
        if not WHEN_RE.search(desc):
            errors.append(f"{d.name}: description should say when to use it")
        if UNSAFE_RE.search(body):
            errors.append(f"{d.name}: contains an unsafe command pattern: {UNSAFE_RE.search(body).group(0)!r}")
        if len(body.splitlines()) > 500:
            errors.append(f"{d.name}: body over 500 lines")
    for e in errors:
        print("FAIL", e)
    print(f"{len(dirs)} skills checked, {len(errors)} problems")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
