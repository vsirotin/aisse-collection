---
name: common-development
description: Common rules for code development that apply across all project types (libraries, CLI tools, services, etc.). Covers development workflow, requirements clarity, bug-fix workflow, logging, coding style, testing discipline, version management, and commit conventions.
metadata:
  author: vsirotin
  version: "1.6"
---

# 1. Common workflow rules

## 1.1 Understanding of project-structure

If the project has a `site-map.md` in its root, read it before you start. It describes the project structure and the search keywords.

If the project works together with other projects (e.g. a client, a server, a project with integration tests), the site map lists them in a section `## Partner projects`: for each partner its location, its role, how it relates to this project and, for a test project, where its test structure is. Read a partner's own agent instructions before you change anything there.

## 1.2 Planning

Before starting a task, make sure you clearly understand the requirements, dependencies, and potential challenges. Then create a short implementation plan that lists the steps needed to complete the task efficiently.
Write the plan into a file. Ask the user for the file name. If the user does not provide one, use `TMP/issues/<issue-id>/plan.md` by default, where `<issue-id>` is a very short name or abbreviation of the problem being solved.
Each step that involves code changes must be verified by running the full unit-test suite (`ALL unit tests`).
Describe each step in its own paragraph with the following structure:
- Name
- State
- Description

State shows the current status of the step, e.g. "Not Started", "In Progress", or "Completed".


## 1.3 Post-task checklist

After completing a task that makes essential changes, apply the [post-task](../post-task/SKILL.md) skill (version bump, release notes, commit text proposal).

# 2. Common Development Rules

## 2.1 Logging by default

All functions with many lines (e.g. more than 10 lines) or short but very important functions must log on entry and before and after important steps (e.g. a call to an external service, important decision points). Logs should be informative and concise.
The whole project uses the same logging library and format.

## 2.2 Consistent coding style

Use best practices of the programming language, but maintain a common, consistent style across the entire project. Do not mix conventions within one codebase.

## 2.3 Document environment dependencies

If a function uses data from environment variables or files, this must be mentioned in the function's documentation.

## 2.4 Radical simplicity (keep programming elements as simple as possible)

1. **Signal/event only when consumed.** A variable is a signal (or event producer) ONLY if something reacts to its changes (an `effect`, a template binding, a subscriber). No such consumer today → plain private field. Converting later is the legitimate small refactor when a consumer appears.
2. **No export without external use.** Do not export a type/constant/function unless another module actually uses it now. Speculative exports irritate future agents and invite misuse.
3. **No speculative future-proofing ("Step N + k" fantasies).** While implementing step N, do not add API for imagined future steps k > 0 — if it is needed, the plan was bad; the legitimate fix is to update the step-N solution in step N + k (e.g. convert a field into a signal, un-private a helper).
4. **Hide state that must not be misused.** State that is not meant for rendering must not be a public signal bindable from templates. Keep it private; tests assert behavior (signals sent, collaborators called), not internal state.


> For testing rules including coverage expectations, naming conventions, organization, execution, and cleanup, see the dedicated [testing](../testing/SKILL.md) skill. Use it when writing, organizing, or running unit tests.

## 2.5 Stop on unsolvable problems

If you see suddenly that you cannot solve some problem, stop the development and ask the user.

## 2.6 Stop on long bug-fix loops

If you try to fix the same bug too long (more than 20 iterations), stop the development and ask the user.

## 2.7 Whole-file responsibility

The agent that changes a file is responsible for the whole file, not only the changed lines. After editing a file, review all of it:

1. Header, class docs, comments, structure and naming match the current code. No dead or duplicated comment blocks, no stale TODOs.
2. Docs do not refer to volatile things (plans, issues, release notes, "Step 3"). Only architecture documents may be referenced.
3. After a rename or move, a search for the old name over the sources, tests and docs finds nothing unexplained.
4. Comments describe the present code, not its history. History is in git and the release notes.

A project may add its own review rules for this (e.g. in a review skill).

# 3. Rules for special task types

## 3.1 Feature development

> For the full feature development workflow, see the dedicated [feature-development](../feature-development/SKILL.md) skill. Use it when implementing new functionality, processing feature requests, or adding new features.

## 3.2 Bug fixing

> For TDD-based bug fixing, see the dedicated [bug-fixing](../bug-fixing/SKILL.md) skill. Use it when investigating, reproducing, and resolving reported defects or unexpected behavior.
