---
name: common-development
description: Common rules for code development that apply across all project types (libraries, CLI tools, services, etc.). Covers development workflow, requirements clarity, bug-fix workflow, logging, coding style, testing discipline, version management, and commit conventions.
metadata:
  author: vsirotin
  version: "1.4"
---

## 1. Common workflow rules

### 1.1 Understanding of project-structure

- If the workflow or some project has in root file `site-map.yaml`, read it to locate relevant files.

## 1.2 Post-task checklist

After completing a task that makes essential changes, apply the [post-task](../post-task/SKILL.md) skill (version bump, release notes, commit text proposal).

# 2. Common Development Rules

## 2.1 Logging by default

All functions with many lines (e.g. more as 10 lines)  or short, but very importanf functions must include logging by enty and before and after important steps (e.g. call to external service, important decision points, etc.). Logs should be informative and concise.
In whole project should be use the same logging library and format.

## 2.2 Consistent coding style

Use best practices of the programming language, but maintain a common, consistent style across the entire project. Do not mix conventions within one codebase.

## 2.3 Document environment dependencies

If a function uses data from environment variables or files, this must be mentioned in the function's documentation.

> For testing rules including coverage expectations, naming conventions, organization, execution, and cleanup, see the dedicated [testing](../testing/SKILL.md) skill. Use it when writing, organizing, or running unit tests.

## 2.4 Stop on unsolvable problems

If you see suddenly that you cannot solve some problem, stop the development and ask me.

## 2.5 Stop on long bug-fix loops

If you try to fix the same bug too long (more than 20 iterations), stop the development and ask me.


## 3. Rules for special task types

### 3.1 Feature development

> For the full feature development workflow, see the dedicated [feature-development](../feature-development/SKILL.md) skill. Use it when implementing new functionality, processing feature requests, or adding new features.

### 3.2 Bug fixing

> For TDD-based bug fixing, see the dedicated [bug-fixing](../bug-fixing/SKILL.md) skill. Use it when investigating, reproducing, and resolving reported defects or unexpected behavior.
