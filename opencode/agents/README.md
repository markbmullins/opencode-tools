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

This library is designed to support a practical multi-agent development workflow:

- `dev` as the main orchestrator
- `docs-researcher` for documentation lookup and synthesis when needed
- `systems-architect` for architecture and planning when the task is large enough
- `backend-engineer`, `frontend-engineer`, or `mcp-server-architect` for implementation depending on domain
- `code-reviewer` for read-only engineering review before merge
- `test-engineer` for coverage and verification analysis
- `security-auditor` for security-focused review
- `production-readiness-reviewer` for launch and operational safety review when needed

---

## Agents

### `backend-engineer`

**Senior backend engineer** for server-side systems, APIs, data models, persistence, integrations, background jobs, and authentication.

Prioritizes correctness, security, operational reliability, and maintainability. Covers the full request lifecycle: input validation, authorization, business rules, persistence, retries, idempotency, and observability.

> Use for: implementing or reviewing backend features, REST/GraphQL API design, debugging server-side failures, improving reliability behavior, and reviewing code for production correctness.

---

### `frontend-engineer`

**Senior frontend engineer** for UI behavior, components, styling, client-side state, accessibility, responsiveness, and browser-side debugging.

Prioritizes correct user-visible behavior, maintainable state flow, accessibility, and consistency with the existing frontend architecture.

> Use for: implementing or reviewing pages and components, debugging frontend state issues, improving accessibility or responsive behavior, and shipping user-facing changes.

---

### `docs-researcher`

**Documentation research agent** for finding, reading, and synthesizing framework, protocol, vendor, and internal project docs.

Optimized for grounding implementation decisions in primary documentation before coding.

> Use for: checking framework behavior, extracting exact API constraints, comparing docs with current code, and producing concise implementation guidance from docs.

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

### `code-reviewer`

**Senior engineering reviewer** for read-only review of the current change set.

Focuses on bugs, regressions, risky edge cases, and missing tests in recently changed code rather than broad launch-process concerns.

> Use for: reviewing diffs before merge, checking for behavioral regressions, surfacing missing test coverage, and validating that a change fits repository conventions.

---

### `test-engineer`

**QA and verification specialist** for reviewing test strategy, coverage depth, missing proof, and bug-reproduction tests.

Focuses on whether the current evidence actually proves the change works, and where the test suite is still blind.

> Use for: coverage-gap analysis, test design review, proving bug fixes, and deciding whether verification is strong enough.

---

### `security-auditor`

**Security review specialist** for identifying practical vulnerabilities, weak trust boundaries, and missing hardening steps.

Focuses on exploitable issues in input validation, authentication, authorization, secrets handling, dependency risk, and external integrations.

> Use for: security-focused review of diffs, auth and data-handling changes, hardening passes, and threat-oriented assessments before release.

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
description: >- # shown to the model when selecting agents
  When to use this agent...
mode: all # primary | subagent | all (default)
---
Agent system prompt...
```

The markdown filename becomes the agent name. For example, `code-reviewer.md` creates the `code-reviewer` agent.

The `description` field is used by the orchestrating model to decide which agent to invoke. Keep it accurate and specific to avoid misrouting.

Other supported frontmatter fields: `model`, `temperature`, `top_p`, `steps`, `permission`, `color`, `hidden`. See the [Agents docs](https://opencode.ai/docs/agents/) for the full reference.

---

## Adding an Agent

1. Create a new `.md` file in this directory.
2. Add frontmatter with at least `description` and, optionally, `mode`.
3. Use the filename as the agent identifier.
4. Write the system prompt below the `---` separator.
5. Keep the agent narrowly scoped — broad agents get misused.

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
