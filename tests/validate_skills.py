"""Static checks for .claude/skills/*/SKILL.md frontmatter.

Catches the failure modes seen in the wild (e.g. pstack#4: names with spaces
break invocation outside Cursor).
"""
import pathlib
import re
import sys

import yaml  # PyYAML

ROOT = pathlib.Path(__file__).resolve().parent.parent / ".claude" / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
WHEN_RE = re.compile(r"\buse (when|for|at|before|after)\b", re.IGNORECASE)
# Community audits of pstack flagged these as unsafe in shared skills.
UNSAFE_RE = re.compile(r"sudo |curl [^\n|]*\| *(ba)?sh|push --force|push -f\b|--force-with-lease|gh pr merge|@latest", re.IGNORECASE)
# Claude Code silently ignores unknown keys, so a typo (disable_model_invocation)
# quietly changes behaviour. Source: code.claude.com/docs/en/skills.md
KNOWN_FIELDS = {"name", "description", "when_to_use", "argument-hint", "disable-model-invocation",
                "user-invocable", "allowed-tools", "model", "effort", "context", "agent",
                "hooks", "paths", "shell"}
BOOL_FIELDS = {"disable-model-invocation", "user-invocable"}
BOOL_VALUES = {"true", "false"}
# Descriptions are injected into the system prompt and should be third person.
PRONOUN_RE = re.compile(r"\b(I|me|my|you|your)\b")
QUOTED_RE = re.compile(r'"[^"]*"|\'[^\']*\'')
LISTING_CAP = 1536      # Claude Code truncates description + when_to_use here
PORTABLE_CAP = 1024     # Agent Skills spec / API limit
TARGET_CAP = 500        # keep listing-budget friendly
IMPERATIVES = {"interview", "work", "turn", "compress", "re-pitch", "verify", "find", "run", "use",
               "write", "review", "build", "create", "make", "before", "after"}
# Built-in / bundled Claude Code skills and commands a project skill must not shadow.
RESERVED = {"code-review", "simplify", "init", "review", "security-review", "loop", "run", "prototype",
            "verify", "run-skill-generator", "schedule", "fewer-permission-prompts", "update-config",
            "keybindings-help", "claude-api", "workflow-authoring", "plugin-authoring", "dataviz",
            "artifact-design", "artifact-diagramming", "artifact-capabilities", "claude-in-chrome", "synced"}
# claude.ai uploads / the Skills API reject XML-like tags in descriptions (claude-code#80469, #26254).
TAG_RE = re.compile(r"<[A-Za-z/][^>]*>")
# Claude Code substitutes $0..$19 in a skill body when it is invoked with arguments
# (claude-code#79859, #91957, #94065), silently corrupting text such as "$1 per run".
ARG_TOKEN_RE = re.compile(r"(?<!\\)\$(\d+)")
# YAML 1.1 reads yes/no/on/off as booleans; only literal true/false is portable.
# Captures empty values and ignores trailing comments.
RAW_BOOL_RE = re.compile(r"^(disable-model-invocation|user-invocable):[ \t]*([^\s#]*)[ \t]*(?:#[^\n]*)?\r?$", re.M)
PERSONAL = pathlib.Path.home() / ".claude" / "skills"


def parse_frontmatter(text):
    """Parse with a real YAML parser: an unquoted ': ' inside a value is
    invalid YAML and can make the harness reject the whole skill."""
    if not text.startswith("---\n"):
        return None, "missing opening ---"
    end = text.find("\n---", 4)
    if end == -1:
        return None, "missing closing ---"
    try:
        data = yaml.safe_load(text[4:end])
    except yaml.YAMLError as e:
        return None, "invalid YAML frontmatter: " + str(e).splitlines()[0]
    if not isinstance(data, dict):
        return None, "frontmatter is not a mapping"
    fields = {k: ("" if v is None else str(v).lower() if isinstance(v, bool) else str(v)) for k, v in data.items()}
    return fields, text[end + 4:]


def main():
    errors, warnings = [], []
    dirs = sorted(p for p in ROOT.iterdir() if p.is_dir())
    for d in dirs:
        f = d / "SKILL.md"
        # Exact-case check: Windows/macOS find "skill.md" via SKILL.md, Linux won't.
        if "SKILL.md" not in {c.name for c in d.iterdir()}:
            errors.append(f"{d.name}: no file named exactly SKILL.md")
            continue
        text = f.read_text(encoding="utf-8")
        fm, body = parse_frontmatter(text)
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
        for key in fm:
            if key not in KNOWN_FIELDS:
                errors.append(f"{d.name}: unknown frontmatter field '{key}' (silently ignored)")
        for key, raw in RAW_BOOL_RE.findall(text.split("\n---", 1)[0]):
            if raw not in BOOL_VALUES:
                errors.append(f"{d.name}: {key} must be literally true or false, got '{raw}'")
        if TAG_RE.search(desc):
            errors.append(f"{d.name}: description contains an XML-like tag {TAG_RE.search(desc).group(0)!r} (rejected by claude.ai/API uploads)")
        m = ARG_TOKEN_RE.search(body)
        if m:
            errors.append(f"{d.name}: body contains '${m.group(1)}', which Claude Code replaces with an argument; escape it as '\\${m.group(1)}'")
        if (PERSONAL / name).is_dir():
            warnings.append(f"{d.name}: a personal copy at {PERSONAL / name} overrides this project skill")
        if "claude" in name or "anthropic" in name:
            errors.append(f"{d.name}: name may not contain 'claude' or 'anthropic'")
        if not 40 <= len(desc) <= PORTABLE_CAP:
            errors.append(f"{d.name}: description length {len(desc)} not in 40..{PORTABLE_CAP}")
        elif len(desc) > TARGET_CAP:
            errors.append(f"{d.name}: description {len(desc)} chars; keep <= {TARGET_CAP} for the listing budget")
        if len(desc) + len(fm.get("when_to_use", "")) > LISTING_CAP:
            errors.append(f"{d.name}: description + when_to_use over {LISTING_CAP}, will be truncated")
        unquoted = QUOTED_RE.sub("", desc)
        if PRONOUN_RE.search(unquoted):
            errors.append(f"{d.name}: description should be third person (found '{PRONOUN_RE.search(unquoted).group(0)}')")
        if desc.split()[0].lower() in IMPERATIVES:
            errors.append(f"{d.name}: description starts with an imperative ('{desc.split()[0]}'); use third person, e.g. 'Interviews...'")
        manual = fm.get("disable-model-invocation", "false").lower() == "true"
        # Only auto skills need trigger conditions: a manual skill's description is
        # never in the model's context, it is just the /-menu label.
        if not manual and not WHEN_RE.search(desc):
            errors.append(f"{d.name}: description should say when to use it")
        if UNSAFE_RE.search(body):
            errors.append(f"{d.name}: contains an unsafe command pattern: {UNSAFE_RE.search(body).group(0)!r}")
        if len(body.splitlines()) > 500:
            errors.append(f"{d.name}: body over 500 lines")
    for w in warnings:
        print("WARN", w)
    for e in errors:
        print("FAIL", e)
    print(f"{len(dirs)} skills checked, {len(errors)} problems")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
