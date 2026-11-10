---
name: issue-stack
description: Process several GitHub issues of a project one after another as a stack of pull requests - for each issue its own branch on top of the previous one, its own commit(s) and its own PR whose base is the previous branch, so that the user reviews and merges them one by one on GitHub or in the IDE. Use when the user names a list or range of issues to process ("issues 30-33", "#12 #14 #15") and wants PRs instead of direct commits.
metadata:
  author: vsirotin
  version: "1.0"
---

# Process issues as a stack of pull requests

The user names issues, e.g. `30-33`. You process them in the given order. Each issue gets a branch that starts at
the branch of the previous issue (the first one at the base, `main` unless the user names another), at least one
commit and a pull request whose base is the previous branch:

```
main ← issue-30-<slug> ← issue-31-<slug> ← issue-32-<slug> ← issue-33-<slug>
        PR base: main     PR base: issue-30   PR base: issue-31   PR base: issue-32
```

Each PR therefore shows only the changes of its own issue. When the user merges the first PR with a merge commit
and deletes its branch, GitHub retargets the next PR to `main`, and it still shows only its own changes.

Starting this skill is the user's explicit request to create branches, commit, push and open PRs for the named
issues. It covers nothing else (no merges, no force pushes, no changes in other repositories without asking).

## Before the first issue

1. Read the project's `CLAUDE.md` and the skills it names. They define the checks (tests, lint, type-check), the
   post-task bookkeeping and the commit script. Everything below uses them; this skill only adds the branching.
2. `git status` must be clean. `git fetch origin`; the base branch must be equal to `origin/<base>`. If the current
   branch has commits that are not in the base, stop and ask: they are either merged first or become the base.
3. Read all named issues (`gh issue view <n> --comments`). If an issue is closed, unclear or needs a decision of the
   user, ask now, before the first branch, and not in the middle of the stack. Ask also when the order of the
   issues matters (one needs the result of another) and differs from the given order.
4. Check the repository settings once:
   `gh api repos/<owner>/<repo> -q '.allow_merge_commit, .delete_branch_on_merge'`. Merge commits must be
   allowed. GitHub retargets the next PR to the default branch only when GitHub itself deletes the merged branch:
   by the setting "Automatically delete head branches" (`delete_branch_on_merge`) or by the "Delete branch"
   button on the PR page of github.com. A deletion by `git push --delete`, which is what the IDE's "Delete
   branch" does, closes the next PR instead. If the setting is off, propose to the user to switch it on.

## For each issue

1. **Branch.** `git switch -c issue-<n>-<slug> <parent>`, where `<parent>` is the base for the first issue and the
   previous issue's branch afterwards; `<slug>` is 2 to 4 words of the title in kebab case. Then
   `git push -u origin issue-<n>-<slug>`, so that the commit script's plain `git push` has an upstream.
2. **Work** on the issue as the project's skills require (bug-fixing with TDD, feature-development; plan in
   `TMP/issues/<n>/plan.md`). Change only what the issue needs.
3. **Checks.** Run all checks the project's `CLAUDE.md` requires before a commit, in full.
4. **Bookkeeping** per the post-task skill: one new version per issue, release-notes line and commit text with
   `Refs <owner>/<repo>#<n>`.
5. **Commit** with the project's commit script (it commits everything and pushes to the issue branch). Usually one
   commit per issue.
6. **Pull request.**
   `gh pr create --base <parent> --head issue-<n>-<slug> --title "<issue title> (#<n>)" --body-file <file>`.
   The body: what changed and why (short), the checks with their results, the version, `Closes #<n>`, and the
   position in the stack (`Stack 2/4: base #<previous PR>, next: #<next PR> once it exists`). After creating a PR,
   add the link to it in the body of the previous PR (`gh pr edit <prev> --body-file ...`). The issue is closed by
   GitHub when its PR is merged into the default branch; do not close it yourself.

## When something goes wrong

- **A check fails and the fix is not within the issue:** stop the stack. Do not commit or open a PR for this issue;
  leave its branch locally, report the failure with its output and what the next issues would have been.
- **A question comes up during the work** that the issue does not answer: stop and ask. Do not guess and do not skip
  the issue silently.
- **The issue needs changes in a partner project:** ask first. The partner gets its own branch from its own default
  branch and its own PR (not part of this stack); both PR bodies link each other and state the merge order (the
  project that owns the rule or interface first), following the bug-fixing skill, "Bugs across several projects".

## Review fixes and rejected PRs (when the user asks)

- **Changes requested in PR k.** Commit the fix on PR k's branch. The PR is not released yet, so it keeps its
  version and build; extend its release-notes line and commit text instead. This keeps the version carriers free of
  conflicts in the later branches. Then pass the fix down: for each later branch in order,
  `git switch <branch>; git merge <previous branch>`, run the checks, `git push`. A conflict in `release-notes.md`
  is resolved by keeping both lines, the later one on top.
- **PR k is rejected.** Close it with a comment. If the later issues do not depend on it, ask the user before
  rebuilding them on PR k's base (`git rebase --onto <base of k> <branch of k> <branch k+1>`, version carriers
  renumbered, `git push --force-with-lease`, `gh pr edit <PR k+1> --base <base of k>`). Otherwise the later PRs are
  closed too.

## Final report

A table: position, issue, branch, PR base, PR link, version, checks. Then the merge instructions for the user:

1. Merge the PRs in stack order, each with **Create a merge commit** (not squash, not rebase: those rewrite the
   commits, and the next PR would show the changes of the merged one again).
2. With "Automatically delete head branches" on, GitHub deletes the merged branch and retargets the next PR; in
   the IDE delete at most the local branch. With the setting off, delete the merged branch only by the button
   on the PR page of github.com, never from the IDE or by `git push --delete`: that closes the next PR.
3. **After the last merge, pull `main`.** The IDE switches to the default branch after a merge, but does not
   download the merged commits: the local branch stays behind GitHub (the IDE's status bar shows e.g. `↓2` next to
   the branch name). Pull it: in VS Code the sync icon next to the branch name in the status bar, or Source Control
   → `…` → Pull, or the command palette "Git: Pull"; in a terminal `git switch main && git pull`. Then the version
   carrier on the default branch shows the version of the last PR of the stack.
4. Delete the local issue branches (all merged): in VS Code Source Control → `…` → Branch → Delete Branch, or
   `git branch -d <branch>...` (refuses a branch that is not merged).

When the user reports the merges are done, check it (`git fetch --prune`, `gh pr list --state all`,
`git status -sb`) and give step 3 and 4 again with the actual numbers (how many commits behind, which branches).

If a next PR was closed by such a deletion: push the merged branch again from the local copy
(`git push origin <branch>:<branch>`), `gh pr reopen <next>`, `gh pr edit <next> --base <default branch>`; the
pushed branch can then be deleted.
