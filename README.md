
# OpenCode Setup

This guide ensures your OpenCode agents in this repo are available across all machines with zero friction.


## Standard Path

Clone this repo to the same location on every machine:

```bash
~/dev/opencode-tools
```

## Install direnv

### macOS (zsh)

```bash
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

Restart shell.

---

### WSL (bash)

```bash
sudo apt install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
```

Restart shell.

---

## Clone Repo

```bash
git clone git@github.com:YOUR_USERNAME/opencode-tools.git ~/dev/opencode-tools
```

---

## Global Fallback (Recommended)

Add this to your shell config:

### macOS

```bash
~/.zshrc
```

### WSL

```bash
~/.bashrc
```

Add:

```bash
export OPENCODE_PATHS="${OPENCODE_PATHS:-$HOME/dev/opencode-tools}"
```

---

## How It Works

* If a project defines `OPENCODE_PATHS` → that is used
* Otherwise → falls back to this repo

Result:

* Zero config in most repos
* Still overrideable when needed

---

## Project Override (Optional)

If a project needs explicit control:

Create `.envrc`:

```bash
export OPENCODE_PATHS=$HOME/dev/opencode-tools
```

Then allow it:

```bash
direnv allow
```

---

## Verify

From any project:

```bash
opencode
```

Your agents should be available.

---

## Recommended Workflow

Use `dev` as the main agent and let it selectively route work to specialist agents.

Suggested flow:

1. `dev` owns the task end to end.
2. `docs-researcher` is used only when the task depends on unfamiliar docs, APIs, frameworks, or protocol details.
3. `systems-architect` is used only when the problem needs real planning, design tradeoffs, or a phased approach.
4. `backend-engineer`, `frontend-engineer`, or `mcp-server-architect` handle specialist implementation depending on where the complexity sits.
5. `code-reviewer` reviews substantial changes before merge.
6. `production-readiness-reviewer` is reserved for launch-risk, migration, rollout, or operational-safety review.

This keeps the default path lightweight while still giving you specialist depth when the task warrants it.

---

## Agent Map

- `dev`: main orchestrator and default agent
- `docs-researcher`: docs lookup, synthesis, and implementation guidance
- `systems-architect`: architecture and planning
- `backend-engineer`: backend implementation and review
- `frontend-engineer`: frontend implementation and review
- `mcp-server-architect`: MCP-specific design and implementation
- `code-reviewer`: read-only engineering review of changes
- `production-readiness-reviewer`: launch and operational safety review

---

## Example Usage

Prompts that fit this setup well:

- `Use dev to add tenant-aware rate limiting to the API. Check docs first if the framework behavior is unclear.`
- `@docs-researcher summarize the latest docs for Next.js server actions caching and revalidation.`
- `@systems-architect propose a phased design for splitting background jobs out of the monolith.`
- `@backend-engineer implement the webhook retry worker described in this issue.`
- `@frontend-engineer fix the mobile navigation state bug and keep the current design language.`
- `@mcp-server-architect design an MCP server that exposes internal docs search and ticket lookup.`
- `@code-reviewer review the current diff for bugs and missing tests.`

---

## Notes

- Do NOT use symlinks
- Do NOT copy agents between repos
- Always keep this repo as the single source of truth
