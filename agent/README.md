```
/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
/\  ___                                 _       /\
\/ / _ \ _ __   ___ _ __   ___ ___   __| | ___  \/
/\| | | | '_ \ / _ \ '_ \ / __/ _ \ / _` |/ _ \ /\
\/| |_| | |_) |  __/ | | | (_| (_) | (_| |  __/ \/
/\ \___/| .__/ \___|_| |_|\___\___/ \__,_|\___| /\
\/   / \|_|__ _  ___ _ __ | |_ ___              \/
/\  / _ \ / _` |/ _ \ '_ \| __/ __|             /\
\/ / ___ \ (_| |  __/ | | | |_\__ \             \/
/\/_/   \_\__, |\___|_| |_|\__|___/             /\
\/        |___/                                 \/
/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
```

# Agent Library

A collection of specialized AI agent definitions for [opencode](https://opencode.ai). Each agent is scoped to a specific engineering or product discipline, with a focused persona, operating approach, and quality bar.

---

## Agents

### `backend-engineer`

**Senior backend engineer** for server-side systems, APIs, data models, persistence, integrations, background jobs, and authentication.

Prioritizes correctness, security, operational reliability, and maintainability. Covers the full request lifecycle: input validation, authorization, business rules, persistence, retries, idempotency, and observability.

> Use for: implementing or reviewing backend features, REST/GraphQL API design, debugging server-side failures, improving reliability behavior, and reviewing code for production correctness.

---

### `systems-architect`

**Senior systems architect** for designing and evaluating software platform architectures.

Analyzes requirements and operational realities to recommend architectures and surface tradeoffs. Reasons across component boundaries, data flows, failure modes, scalability, and operational cost. Can produce architecture briefs and ADRs.

> Use for: planning new systems, comparing monolith vs microservices, evaluating storage strategies, phased migration planning, and any decision requiring structured reasoning about system shape.

---

### `product-manager`

**Senior product manager** for turning ambiguous requests into clear, actionable product direction.

Works through problem framing, user value, scope control, tradeoff analysis, and rollout safety. Produces briefs, user stories, acceptance criteria, prioritization notes, and product reviews of shipped work.

> Use for: clarifying vague feature requests, prioritizing competing options, writing structured requirements, reviewing launched features for product gaps, and launch readiness assessments.

---

### `delivery-ticket-writer`

**Tech lead** for converting architecture documents, RFCs, and implementation plans into a delivery-ready engineering backlog.

Decomposes technical designs into sequenced, scoped tickets with clear purpose, acceptance criteria, dependencies, and implementation notes. Targets 0.5–3 days of work per ticket.

> Use for: translating approved design docs into Jira-style tickets, breaking down large initiatives, and bridging the gap between design and execution.

---

### `mcp-server-architect`

**Expert MCP (Model Context Protocol) architect** for designing, implementing, reviewing, and troubleshooting MCP servers and clients.

Covers the full MCP lifecycle: capability design (tools, resources, prompts), protocol implementation (JSON-RPC), integration patterns, client interaction, and operational hardening. Prioritizes clarity, interoperability, security, and production readiness.

> Use for: designing new MCP servers, defining tool/resource schemas, debugging client-server interoperability issues, reviewing MCP implementations, and improving protocol safety.

---

### `production-readiness-reviewer`

**Senior staff engineer** conducting production readiness reviews before launch, release, or major traffic increases.

Evaluates reliability, scalability, observability, deployment safety, rollback feasibility, security, and operational burden. Classifies findings as `blocker`, `major`, `minor`, or `note` and delivers a clear launch verdict.

> Use for: pre-launch reviews of services or features, migration safety assessments, rollout risk evaluation, and verifying that operators can detect and recover from failures quickly.

---

## File Format

Each agent is defined in a Markdown file with a YAML frontmatter block:

```yaml
---
name: agent-name # used to invoke the agent
description: >- # shown to the model when selecting agents
  When to use this agent...
mode: all # primary | subagent | all (default)
---
Agent system prompt...
```

The `description` field is used by the orchestrating model to decide which agent to invoke. Keep it accurate and specific to avoid misrouting.

Other supported frontmatter fields: `model`, `temperature`, `top_p`, `steps`, `permission`, `color`, `hidden`. See the [Agents docs](https://opencode.ai/docs/agents/) for the full reference.

---

## Adding an Agent

1. Create a new `.md` file in this directory.
2. Add frontmatter with `name`, `description`, and `mode`.
3. Write the system prompt below the `---` separator.
4. Keep the agent narrowly scoped — broad agents get misused.

You can also run `opencode agent create` for an interactive setup wizard.

---

## Docs

| Topic                                                   | Link                                                                  |
| ------------------------------------------------------- | --------------------------------------------------------------------- |
| Agents — file format, modes, frontmatter fields         | [opencode.ai/docs/agents](https://opencode.ai/docs/agents/)           |
| MCP Servers — local and remote server config, OAuth     | [opencode.ai/docs/mcp-servers](https://opencode.ai/docs/mcp-servers/) |
| Skills — reusable instruction definitions (`SKILL.md`)  | [opencode.ai/docs/skills](https://opencode.ai/docs/skills/)           |
| Tools — built-in tool reference                         | [opencode.ai/docs/tools](https://opencode.ai/docs/tools/)             |
| Permissions — allow/deny/ask rules for tools and agents | [opencode.ai/docs/permissions](https://opencode.ai/docs/permissions/) |
| Models — configuring and overriding models              | [opencode.ai/docs/models](https://opencode.ai/docs/models/)           |
| models.dev — model browser and capability reference     | [models.dev](https://models.dev/)                                     |
| Config — global `opencode.json` reference               | [opencode.ai/docs/config](https://opencode.ai/docs/config/)           |
