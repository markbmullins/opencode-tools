# OpenCode portable source of truth

This repo is the canonical, portable source of truth for your OpenCode setup.

The repo owns authored agents, authored skills, vendored third-party skills, and shared OpenCode config. Machine-local paths like `~/.config/opencode` and `~/.agents/skills` are treated as generated runtime state.

## Layout

```text
opencode/
  agents/            # authored agent files
  skills/
    authored/        # skills you write and maintain here
    vendor/          # third-party skills copied into the repo
  config/
    opencode.json    # shared OpenCode config
scripts/
  sync-opencode.sh   # repo -> machine sync
  import-skill.sh    # copy an installed skill into vendor/
  doctor-opencode.sh # detect repo/runtime drift
skills-lock.json     # optional install metadata for third-party skills
sync.sh              # compatibility wrapper for sync-opencode.sh
```

## Operating model

- **Repo is canonical**
- **Sync is one-way: repo -> machine**
- **Imports are explicit: machine/project install -> repo vendor tree**

Do not treat `~/.config/opencode` or `~/.agents/skills` as your source of truth.

## Install on a machine

```bash
git clone git@github.com:YOUR_USERNAME/opencode-tools.git
cd opencode-tools
./scripts/sync-opencode.sh
```

Or use the compatibility wrapper:

```bash
./sync.sh
```

You can override the target config root:

```bash
OPENCODE_CONFIG_HOME=/some/path ./scripts/sync-opencode.sh
```

## Sync mapping

The sync script maps repo-owned content into OpenCode runtime paths:

- `opencode/agents/` -> `~/.config/opencode/agents/`
- `opencode/skills/authored/` + `opencode/skills/vendor/` -> `~/.config/opencode/skills/`
- `opencode/config/opencode.json` -> `~/.config/opencode/opencode.json`

If the same skill name exists in both `authored/` and `vendor/`, sync fails closed.

## Add a third-party skill

If `npx skills add` offers **Project** or **Global**, prefer **Project** when it writes into a local folder you control. But the installer may still target paths that are outside this repo's canonical layout.

Recommended workflow:

1. Install the skill with `npx skills add ...`
2. Import it into the repo vendor tree
3. Review and commit the vendored files
4. Run sync

Example:

```bash
npx skills add https://github.com/github/awesome-copilot --skill refactor
./scripts/import-skill.sh refactor
./scripts/sync-opencode.sh
```

`import-skill.sh` looks in common locations such as:

- `$PWD/.agents/skills/<name>`
- `$PWD/.opencode/skills/<name>`
- `~/.agents/skills/<name>`
- `~/.config/opencode/skills/<name>`

You can also pass an explicit source path:

```bash
./scripts/import-skill.sh refactor /path/to/installed/refactor
```

## Add your own skill

Create it directly in:

```text
opencode/skills/authored/<skill-name>/
```

## Verify runtime state

```bash
./scripts/doctor-opencode.sh
opencode debug config
```

`doctor-opencode.sh` reports drift between the repo and your machine runtime copy.

It also warns if legacy project discovery paths like `.agents/skills/` or `.opencode/skills/` still exist in the repo, because those can shadow your new canonical layout.

## Notes

- The repo structure is intentionally independent from OpenCode's discovery paths.
- Runtime locations are deployment targets, not the source of truth.
- Vendoring third-party skills in git makes the setup portable across PCs.
