## Mental Model

- This repo is the single source of truth for OpenCode config.
- Machine state (`~/.config/opencode`, `~/.agents`) is generated — never edit it directly.
- All changes flow: repo → sync scripts → machine.

---

## Architecture

- Canonical layout:
  - `opencode/agents`
  - `opencode/skills/authored`
  - `opencode/skills/vendor`
  - `opencode/config/opencode.json`
- Use `scripts/sync-opencode.sh` to apply repo → machine state.
- `sync.sh` is a compatibility wrapper only.

---

## Rules

- Only modify files inside `opencode/`.
- Do not edit generated machine paths (`~/.config/opencode`, `~/.agents`).
- Do not rely on global installs as source of truth.

---

## Gotchas

- **Global installs bypass the repo**  
  `npx skills add` (Global) writes to `~/.agents/skills`.  
  → Import into `opencode/skills/vendor`, commit `skills-lock.json`, then sync.

- **Legacy paths can cause drift**  
  Ignore `.agents/skills` and `.opencode/skills`.  
  → Use `scripts/doctor-opencode.sh` to detect conflicts.

- **Lore markers are not config-driven**  
  If they reappear, something external is rewriting `AGENTS.md` (plugin/cache).

- **Avoid absolute rules in skills**  
  Prefer strong defaults with rationale over “always/never”.

---

## Patterns

- **AGENTS.md = agent memory**  
  Store constraints, gotchas, and workflow rules here.  
  Put human setup/docs in `README.md`.

- **Keep skills durable**  
  - `SKILL.md` = decisions + workflow  
  - `references/` = volatile details (APIs, commands, examples)

- **Separate skill ownership**  
  - `authored/` = first-party  
  - `vendor/` = imported  
  Never duplicate between them.

- **Verify version-specific behavior**  
  Do not trust memory for fast-moving APIs — check local environment.

---

## Preference

- Keep everything reproducible from git.
- Avoid relying on machine-local or implicit state.