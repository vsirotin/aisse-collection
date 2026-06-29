---
name: post-task
description: Post-task checklist that runs after every agent task that makes essential changes to code, documentation, scripts, or configuration. Covers version bumping, release-notes update, and commit-text proposal. Applied automatically — the agent does not need to be asked.
metadata:
  author: vsirotin
  version: "1.1"
---

# Post-Task Checklist

This skill is applied after every task that makes essential changes to code, documentation, scripts, or configuration files. The agent must execute these steps before reporting completion.

---

# Rules

## 1. Update version

Update version in files, if they exist. First check existing of `sity-map.yaml` in workspace or in project root and read it to locate version files. If `site-map.yaml` does not exist, check for version files (`version.json` or `version.yaml`) in the following order:
1. <root>
2. <root>/src/
4. <project-root>
5. <project-root>/src/

Use semantic versioning rules:

- **Bump `minor`** (e.g. `0.0.0 → 0.0.1`) when adding a user-visible feature or improvement.
- **Bump `patch`** (third digit, e.g. `0.0.1 → 0.0.2`) when fixing a bug or making an invisible internal change.
- **Bump `major`** (e.g. `0.0.x → 0.1.0`) for breaking or significant architectural changes.
- **Increment `build`** by 1 on every change regardless of which version segment was bumped.
- **Update `datetime`** to the current date and time in ISO 8601 format.

Remember the new version.

## 2. Update release notes

Insert the new version entry **at the beginning** (after the header, at line 3) in `<project-root>/release-notes.md` (if it exists). Include the remembered version number and a short explanation of the version update. Latest release appears first, oldest releases appear last. Do not reorder or overwrite previous entries. Increase a value of parameter `build` in `version.yaml` by 1. Update `datetime` to the current date and time in ISO 8601 format.

## 3. Write commit text proposal

Update **only** the workspace-root file: `commit-text-proposal.txt` (in the workspace root directory where this skill file is located, not in sub-project directories).

Rewrite its content with the following format:

```
<prefix>: Project: <project>. Version: <current version>. <short label for update>.
```

**Parameters:**
- `<prefix>` (optional): See prefix table below (e.g., `feat`, `fix`, `dist`).
- `<project>`: Full sub-project path from workspace root (e.g., `telegram/telegram-lib` or `telegram/telegram-cli`).
- `<current version>`: The version from the changed sub-project's `src/version.yaml` after Rule 1.
- `<short label for update>`: Concise description of what changed (2-10 words).

**Multi-sub-project updates:** If the same commit affects multiple sub-projects, mention **only the main/primary sub-project** that drove the changes.

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
fix: Project: telegram/telegram-lib. Version 1.0.12. Closes #9, fix path issue.
nit: Project: telegram/telegram-lib. Version 1.3.12. Swap let for const.
doc: Project: telegram/telegram-lib. Version 2.3.15. Added usage section to README.md.
```

## 4. Commit changes
If the user explicitly requested to commit changes, call the script `scripts/make-commit.sh`.