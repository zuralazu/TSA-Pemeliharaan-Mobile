# Setup Agent First

**Make any repo agent-first.**

[![skills.sh](https://skills.sh/b/hibatillah/setup-agent-first)](https://skills.sh/hibatillah/setup-agent-first)

A skill that builds an AI coding agent an actual understanding of a repo, not just a convention file. It generates `AGENTS.md`, a how-to/reference/explanation doc set (the [Diataxis](https://diataxis.fr) structure) covering the real architecture and domain model, an ADR convention for recording why decisions were made, and matching subagents, commands, and CI, all derived from what your repo actually is, not copied from a template.

Most projects already have an `AGENTS.md` or `CLAUDE.md` telling an agent what to do; few have the docs explaining how the system actually works. This skill closes that gap.

```bash
npx skills add hibatillah/setup-agent-first
```

## What it does

It detects what's already in the repo: stack, existing docs, existing agent-context files, configured tooling. It asks what to add through one batched question. It writes a plan. It only executes after you approve that plan. It never edits application code, only docs, config files, and, if you opt in, subagents, commands, CI workflows, and git hooks.

One flow covers both cases:

- **Fresh repo.** Nothing set up yet. If there's not even a README or manifest to detect from, it stops and asks what the project is before doing anything else.
- **Existing repo.** `AGENTS.md` and a docs index already exist. It switches to a short "what changed since last setup" interview instead of the full flow, so re-running it doesn't redo work or duplicate files.

## What it generates

| Layer | Contents |
|---|---|
| **`AGENTS.md`** | Always generated. The root convention file every other agent-context file points back to. If one already exists, its content is never touched; the generated section is appended inside `<!-- SETUP-AGENT-FIRST:START -->` / `<!-- SETUP-AGENT-FIRST:END -->` markers, and a later run updates only what's between those markers. |
| **Structured docs** | `docs/how-to/`, `docs/reference/`, `docs/explanation/`. Task steps, lookup tables, and rationale kept in separate files instead of one mixed doc. |
| **ADR convention** | A paragraph in `AGENTS.md` for when to record an architecture decision and how to write one. No ADR tooling gets installed; the agent that reads `AGENTS.md` writes the actual records later, when a real decision comes up. |
| **`CONTRIBUTING.md`** | Onboarding steps ending in a "working with an agent" section with example prompts, so a new dev sees what the setup buys them. |
| **Agent-context files** | Thin pointer files (`CLAUDE.md`, `GEMINI.md`, `.cursor/rules`, etc.) for whichever runtimes you use. A few lines each, all pointing at `AGENTS.md`, never a duplicate copy of it. |
| **Automation layer** *(opt-in)* | Subagents and commands generated for your repo's actual tools. `polish` runs whatever lint, format, and typecheck you have configured. `test` uses whatever runner you have. `docs-sync` keeps the docs index from drifting. Plus [CodeGraph](https://github.com/colbymchenry/codegraph) install and init, offered every run. |
| **Tooling** *(opt-in)* | Pre-commit hooks, a CI workflow, a docs-index-drift check. Three independent choices, never bundled. |

Nothing here is templated in from a prior project. If your repo uses eslint, prettier, and vitest, the generated `polish` subagent runs eslint, prettier, and vitest. See [`references/polish-agent-example.md`](references/polish-agent-example.md) for the same subagent generated two different ways from two different stacks.

## How it works

Five phases, run in order. Full detail in [`SKILL.md`](SKILL.md):

1. **Cheap detection.** Glob for existing docs, agent-context files, manifests, every module README in the tree, tooling config. No code read yet.
2. **Scan-depth question.** Light (detection facts only) or deep (dispatches subagents to actually read code). The recommendation is computed from what phase 1 found, not fixed to light.
3. **Run the scan.** Light does nothing further. Deep collects subagent and command candidates plus a per-subsystem summary for the domain-model doc.
4. **Category selection.** One batched question covering docs, agent-context files, automation, and tooling. Every group includes an explicit "None of these" option from the start.
5. **Plan, stop, execute.** Writes a plan file at the repo root, stops and asks "Plan set, should we continue?", and only executes after you answer. The plan file survives an interrupted run and deletes itself on success.

## Non-negotiables

- **The consent gate is absolute.** However much you said "just go" earlier in the conversation, the skill still stops after writing the plan and waits for your approval. That earlier consent predates the plan and doesn't cover it. See "Consent gate" in `SKILL.md`.
- **Derive, never template.** Every stack-facing line it writes, a command, a tool name, a config path, comes from what it found in your repo. Nothing is copy-pasted from a prior run.

## Usage

```
/setup-agent-first
```

The skill only runs when you invoke it directly. It never fires on its own. Pass a short project description as an argument if the repo is empty and has nothing to detect from yet:

```
/setup-agent-first a CLI tool that syncs Notion pages to a local markdown vault
```
