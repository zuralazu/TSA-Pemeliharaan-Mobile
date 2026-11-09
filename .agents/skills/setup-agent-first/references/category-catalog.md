# Phase 4 category catalog

The single batched question for a fresh setup run. Pre-check/pre-fill options from Phase 1/3 findings wherever possible — e.g. if `CLAUDE.md` already exists, it's pre-selected; if a clear domain model exists, the domain-model doc is proposed on.

**Every group below (A/B/C/D) gets an explicit "None of these" option, offered from the start — never add it only after the user selects nothing and gets re-asked.** Selecting "None" for a group is a normal, first-class outcome, not an error state.

## A. Documentation layer (agent-agnostic — offered on every run, plus None)

`AGENTS.md` itself is never optional (see below), but every other row in this group is — include a "None of these" option covering everything except `AGENTS.md`.

| Item | Default | Notes |
|---|---|---|
| `AGENTS.md` | always on, not askable | root convention file, single source of truth every other agent-context file points at. If it already exists, this is always an append (never ask modify-vs-append) inside `<!-- SETUP-AGENT-FIRST:START -->`/`...:END` markers — see SKILL.md § Appending, not overwriting, AGENTS.md |
| Structured docs (how-to / reference / explanation) | proposed on | Don't say "Diataxis" in the question **title** — it's jargon most users won't recognize. Fine to mention in the description for people who do. Title reads like: "Organize docs into how-to / reference / explanation guides?" |
| ADR process | proposed on | No ADR tooling gets built. Only a convention paragraph goes into `AGENTS.md` — see `templates.md#adr-convention` — covering when to offer one, the ask-before-creating rule, file naming, section order. The agent reading `AGENTS.md` later does the actual writing when a real decision comes up. |
| Diagrams (mermaid) | proposed only if domain complexity warrants it (multiple services, non-trivial data model found) | |
| Domain-model explanation doc | proposed only if a clear business domain exists — skip for a CLI tool, library, or infra-only repo | must pass the completeness check in SKILL.md § Phase 4 before it's considered done, regardless of scan depth |
| `CONTRIBUTING.md` | proposed on if missing | structure in `templates.md#contributing` |
| **Existing module/service READMEs** | one row per file Phase 1 found beyond the root README | See "Existing module READMEs" below — never silently skip one. |

### Existing module READMEs

Phase 1 finds these by globbing subdirectories, not just the root. **Every one found gets a decision, individually — never bundle them into a single yes/no.** Two options per file, default is the first:

1. **Keep in place, add a thin pointer doc** — generate a short `docs/explanation/<topic>.md` (or `reference/`, if it's more lookup-table shaped) that states the file is the canonical doc for that subsystem and links to it, then add that pointer to the docs index. This is the default: a module README living next to its code is usually exactly where its authors and its readers expect it, and centralizing would just move it away from the code it describes.
2. **Move the content into the structured docs tree** — only if the user explicitly prefers centralizing everything under `docs/`. Physically relocate the content (don't duplicate it in two places), split across how-to/reference/explanation if it mixes modes, and leave nothing orphaned at the old path.

Whichever option, **every found README ends up either linked from the docs index or physically moved — none are left untouched and unindexed.** That's the exact failure mode this section exists to close: a module README found during detection but never mentioned again anywhere in the generated docs.

## B. Agent-context files (per detected/selected runtime, plus None)

Detect existing files in Phase 1. For each one that's *missing*, ask which runtimes the user actually uses (don't assume — a repo with no agent files yet could target any subset) — include a "None beyond AGENTS.md" option for a user who only wants the universal file.

Every non-`AGENTS.md` file (`CLAUDE.md`, `GEMINI.md`, `.cursor/rules`, `.github/copilot-instructions.md`) is generated as a **thin pointer that imports/references `AGENTS.md`** — never a duplicate copy of its content. A 2–5 line file whose only job is "read AGENTS.md."

## C. Automation layer (Claude Code targets only — gated on deep scan having run — plus None)

Include a "None" option covering the whole group for a user who only wants the documentation layer.

Not shipped as templates — proposed as *capabilities*, generated per-repo at execution time from Phase 1/3 findings (see SKILL.md § Deriving, not templating):

- **`polish`** (command + subagent) — runs this project's lint/format/typecheck and fixes violations. Tool names, commands, and config paths come from the scan, never assumed.
- **`test`** (subagent) — owns writing/fixing tests for this project's actual test layers, using whatever runner the scan found.
- **`docs-sync`** (subagent) — keeps the docs index and `AGENTS.md`'s doc-table in sync whenever docs are added/moved/removed. Same shape regardless of stack — no derivation needed, this one *is* close to a template because its job (index maintenance) has nothing to do with the target's language or tooling.
- **`group-commit`** (command) — only proposed once a commit-grouping convention exists or is being written into `AGENTS.md` in this same run. Skip it otherwise — nothing to group by yet.
- **Domain-specific subagents** — *only* ever proposed from deep-scan findings on the actual repo (e.g. "12 routes repeat the same auth-gating check → propose an auth-focused subagent"). Never part of the starter set, never generic, never proposed without a specific finding backing it.
- **CodeGraph** — always offered as its own checkbox in this group, every run, unconditionally on Claude Code being a target. It never comes from a scan finding, which is exactly why it's easy to forget when building the rest of this group from Phase 1/3 results — check it's present before sending the batch. See SKILL.md § CodeGraph for what selecting it does.
- `settings.json`/permission tuning — only touched if the user opted into something above that needs it. No reason otherwise.

## D. Tooling / process (agent-agnostic, opt-in, three *independent* checkboxes plus None)

- Husky pre-commit (lint/format/typecheck gate) — stack-derived command, same rule as `polish`.
- CI workflow (lint/typecheck/test) — stack-derived.
- **Docs-index-drift CI check** — separate checkbox, never bundled into the two above. Only meaningful if the documentation layer (§A) was also selected; skip offering it otherwise.
- **None of these** — skip the whole tooling/process group. This is the option that was missing when this bug was found: a user declining every item in this group is not a malformed answer that needs re-asking, it's a valid "skip tooling entirely" outcome, offered up front.

## Update-run interview (short form, replaces A–D above when Phase 1 detects an existing setup)

- New docs added since last run that aren't in the index yet? → offer to sync.
- New repeated patterns found (if doing a deep rescan) worth a subagent? → offer to propose.
- Any doc referenced in the index that no longer exists on disk, or vice versa? → offer to fix (this is the exact class of bug a prior manual setup can drift into).
