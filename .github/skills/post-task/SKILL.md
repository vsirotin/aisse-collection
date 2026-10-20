---
name: post-task
description: Post-task checklist that runs after every agent task that makes essential changes to code, documentation, scripts, or configuration. Covers version bumping, release-notes update, and commit-text proposal. Applied automatically — the agent does not need to be asked.
metadata:
  author: vsirotin
  version: "1.4"
---

# Post-Task Checklist

This skill is applied after every task that makes essential changes to code, documentation, scripts, or configuration files. The agent must execute these steps before reporting completion.

The project's agent instructions (e.g. `CLAUDE.md`) may name the concrete version carriers and formats. They take precedence over the defaults below.

---

# Rules

## 1. Update version

Update version in files, if they exist. If the project has a site map (`site-map.md` or `site-map.yaml`) in the workspace or project root, read it to locate the version files. Otherwise check for version files (`version.json` or `version.yaml`) in the following order:
1. <root>
2. <root>/src/
3. <project-root>
4. <project-root>/src/

Use semantic versioning rules:

- **Bump `major`** (e.g. `1.4.2 → 2.0.0`) for breaking or significant architectural changes. Before `1.0.0`, bump `minor` instead.
- **Bump `minor`** (e.g. `0.4.2 → 0.5.0`) when adding a user-visible feature or improvement.
- **Bump `patch`** (e.g. `0.4.2 → 0.4.3`) when fixing a bug or making an invisible internal change, including documentation.
- **Increment `build`** by 1 on every change regardless of which version segment was bumped.
- **Update `datetime`** to the current date and time in ISO 8601 format.

Remember the new version for using in the next step (release notes update).

**IMPORTANT — enumerate ALL version carriers of the affected project(s).** A project's version may be stored in several files that must all be set to the same new version and datetime, e.g.:
- `version.yaml` / `version.json` (and their copies under `src/`)
- `package.json`
- `package-lock.json` (top-level `"version"` and `packages[""].version` — regenerate or edit it whenever `package.json` changes)

Before finishing Rule 1, search the affected project for version files (`find <project-root> -maxdepth 3 -name 'version.yaml' -o -name 'version.json'` plus a `grep '"version"' package*.json`) and update every carrier found. Missing one carrier is the most common versioning mistake.

### Special case with multi-project workspaces.
If the workspace contains multiple sub-projects, you should determine which sub-projects were affected by the changes. If the changes affect multiple sub-projects, you should bump versions in all affected sub-projects. If the changes affect only one sub-project, you should bump version only in that sub-project.

## 2. Update release notes

Insert the new version entry **at the beginning** (after the header) in `<project-root>/release-notes.md` (if it exists). Include the version and build from Rule 1 and a short explanation of the update. Latest release appears first, oldest releases appear last. Do not reorder or overwrite previous entries.
Use the following format for the new entry, unless the existing entries of the file use another one (then follow the file):

```
<prefix>: Project: <project>. Version <version> build <build>. <short label for update>.
```

**Parameters:**
- `<prefix>` (optional): See prefix table below (e.g., `feat`, `fix`, `dist`).
- `<project>`: Full sub-project path from workspace root (e.g., `telegram/telegram-lib` or `telegram/telegram-cli`).
- `<version>`, `<build>`: The values of the changed sub-project's version carriers after Rule 1.
- `<short label for update>`: Concise description of what changed (2-10 words).

Prefixes:

| Prefix      | Meaning                                                        |
|-------------|----------------------------------------------------------------|
| `test`      | Update `test/*` files                                          |
| `dist`      | Changes to submodules, version bumps, updates to `package.json`|
| `minor`     | Small changes                                                  |
| `doc`       | Updates to documentation                                       |
| `fix`       | Bug fixes                                                      |
| `bin`       | Update binary scripts associated with the project              |
| `refactor`  | Refactor of existing code                                      |
| `nit`       | Small code review changes mainly around style or syntax        |
| `feat`      | New features                                                   |

**Examples:**

```
fix: Project: stop-lib. Version 1.0.12 build 40. Closes #9, fix path issue.
nit: Project: stop-server. Version 1.3.12 build 17. Swap let for const.
doc: Project: stop-client. Version 2.3.15 build 102. Added usage section to README.md.
```

The rule for multi-project workspaces is the same as by version-update. 

## 3. Project specific versioning

In multi-project workspaces, determine which sub-projects were affected by the
changes of this task:

1. For each sub-project, check its manifest/config files (e.g. `package.json`,
   `angular.json`, `pom.xml`, etc.) for files changed by this task.
2. If a sub-project was affected, apply Rule 1 (version update) to **its own**
   version file — even if a workspace-level version file also exists.
   A sub-project may have SEVERAL version carriers (e.g. `src/version.json`,
   `version.yaml` and `package.json`) — keep **all** of them in sync with the
   same new version (see the "enumerate ALL version carriers" note in Rule 1,
   including `package-lock.json`).
3. Sub-projects not touched by this task are not bumped.

The goal: each sub-project carries its own version history reflecting only its
own changes.

## 4. Write commit text proposal

Update **only** the workspace-root file: `commit-text-proposal.txt` (in the workspace root directory, not in sub-project directories).

**Multi-sub-project updates:** If the same commit affects multiple sub-projects, write a separate commit-text parts for each sub-project. Each part should include the sub-project name, the new version, and a short description of the changes made. 


## 5. Commit changes
Commit only if the user explicitly requested it. Use the project's commit script if it has one (e.g. `scripts/make-commit.sh`, which commits with `commit-text-proposal.txt` as the message); otherwise commit with the text of `commit-text-proposal.txt`.
