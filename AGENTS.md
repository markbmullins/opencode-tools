<!-- This section is maintained by the coding agent via lore (https://github.com/BYK/loreai) -->
## Long-term Knowledge

### Gotcha

<!-- lore:019dd072-f294-7433-9671-feafb5efa3b5 -->
* **Avoid absolute rules in skill instructions**: Skill guidance should use strong defaults, not universal laws. Overstated rules like 'never store an allocator' or 'always use X' make the skill brittle; prefer wording that explains the tradeoff and allows justified exceptions.

### Pattern

<!-- lore:019dd072-f293-797a-bcf4-571d23ec818c -->
* **Keep SKILL.md lean and move fragile details out**: For project skills, keep the main \`SKILL.md\` focused on durable decision-making rules and workflow. Move version-sensitive APIs, exact command shapes, and detailed examples into \`references/\` files so the skill stays robust when upstream tools or languages change.

<!-- lore:019dd072-f294-7433-9671-feb08d00856a -->
* **Tell skills to verify local version-specific APIs**: When a skill depends on exact stdlib, build, or toolchain APIs, include an instruction to verify against the local installed version instead of relying on memory. This is especially important for fast-moving ecosystems where examples can become confidently wrong.
<!-- End lore-managed section -->
