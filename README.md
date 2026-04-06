# OpenCode Config

Portable OpenCode setup for custom agents and shared skills.

This repo is the source of truth for:

- `agents/` — custom OpenCode agents authored in this repo
- `.agents/skills/` — installed skills managed by `npx skills`
- `opencode.json` — shared OpenCode config
- `skills-lock.json` — reproducible skill installs

## Why this layout

This follows OpenCode's documented discovery paths:

- project agents: `.opencode/agents/`
- global agents: `~/.config/opencode/agents/`
- project skills: `.opencode/skills/`, `.claude/skills/`, or `.agents/skills/`
- global skills: `~/.config/opencode/skills/`, `~/.claude/skills/`, or `~/.agents/skills/`

We keep skills in `.agents/skills/` inside the repo because `npx skills add ...` installs there directly.

## Repo structure

```text
agents/           # repo-authored OpenCode agents
.agents/skills/   # installed skills managed by `npx skills`
opencode.json     # shared config
skills-lock.json  # skill lockfile
sync.sh           # sync repo into ~/.config/opencode
```

## Install

Clone anywhere you want:

```bash
git clone git@github.com:YOUR_USERNAME/opencode-tools.git
cd opencode-tools
./sync.sh
```

The script syncs this repo into the documented global OpenCode paths:

- `agents/` → `~/.config/opencode/agents/`
- `.agents/skills/` → `~/.config/opencode/skills/`
- `opencode.json` → `~/.config/opencode/opencode.json`

You can override the target root with:

```bash
OPENCODE_CONFIG_HOME=/some/path ./sync.sh
```

## Add a skill

From the repo root:

```bash
npx skills add https://github.com/github/awesome-copilot --skill documentation-writer
```

That installs the skill into `.agents/skills/` in this repo. Then run:

```bash
./sync.sh
```

to copy it into your global OpenCode config.

## Verify

Check your resolved config:

```bash
opencode debug config
```

Check synced files:

```bash
ls ~/.config/opencode/agents
ls ~/.config/opencode/skills
```

## Notes

- `.claude/` and `.windsurf/` are intentionally ignored in this repo
- `agents/` is for authored agents
- `.agents/skills/` is for installed skills
- `sync.sh` is the install step that makes the repo portable across machines
