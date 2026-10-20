---
name: review
description: Architecture code review for Angular projects. Checks changed files against the rules of the angular-development skill (modules, DI, contracts, SFSM, categories), plus whole-file hygiene and test rules, with one rule file per kind of file. Use it when reviewing a diff, a pull request, a set of changed files, or your own work before reporting it as done.
metadata:
  author: vsirotin
  version: "1.1"
---

# Architecture code review

The rule IDs (M, D, C, S, K) are defined in the [angular-development](../development/SKILL.md) skill. The rule files below say how to check them per kind of file, and add review-only rules (W, T, U).

**Scope.** The whole-file (W), test (T) and UI layout (U) rules apply to every Angular project. The M, D, C, S, K checks apply only to projects with state-oriented architecture (they have `specs/frontend-architecture/frontend-architecture.md` and `site-map.md`).

## 1. Setup

1. Collect the changed files: `git diff --name-only <base>...HEAD` plus uncommitted changes, or the files edited in the current task.
2. Run the project's lint (e.g. `npm run lint`). Every lint error is a **Blocker**; report it and do not repeat its check by hand.
3. Assign each changed file to one or more kinds and apply the matching rule files:

| Kind of file | Rule file |
|--------------|-----------|
| every changed file | [review-rules-whole-file.md](review-rules-whole-file.md) |
| new, moved or deleted directory; any `index.ts`; `tsconfig.json`, `vitest.config.ts`, `eslint.config.mjs`, `site-map.md` | [review-rules-directory.md](review-rules-directory.md) |
| production `*.ts` outside `src/app/ui` | [review-rules-production-ts.md](review-rules-production-ts.md) |
| `*.ts`, `*.html`, `*.scss` under `src/app/ui` | [review-rules-ui-component.md](review-rules-ui-component.md) and the production rules where they apply |
| `sfsm.json` and controller command or signal methods | [review-rules-sfsm.md](review-rules-sfsm.md) |
| `*.spec.ts`, `test/**` | [review-rules-spec-ts.md](review-rules-spec-ts.md) |

4. Read the whole changed file, not only the diff. A violation in an untouched part of a changed file is still reported (rule W1).

## 2. Severity

- **Blocker:** lint errors; M2, M4, D1, D2, C1, C3, S3. They break the architecture.
- **Major:** the other M, D, C, S, K rules; T1–T4; U1–U3; W3.
- **Minor:** W1, W2, W4 and T5–T6. Propose them as follow-up nits.

Report only rule violations, not personal style preferences.

## 3. Report

| # | Severity | Rule | File:Line | Issue | Suggested fix |
|---|----------|------|-----------|-------|---------------|

End with one verdict: "Ready to merge", "Fix Blockers/Majors first", or a short list of required changes.

## 4. When a rule is missing

If you find a problem that no rule covers but that the architecture spec forbids, report it as Major with rule "spec" and propose a new rule (ID and one sentence) for the rule file. If a rule can be checked mechanically, propose adding it to the project's lint configuration or architecture check scripts instead.
