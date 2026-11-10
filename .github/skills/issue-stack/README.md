# issue-stack: notes for the people who review and merge

The agent's instructions are in `SKILL.md`. This file explains what happens on GitHub around a stack of pull requests,
so that you can merge it safely.

## The stack

Each issue gets its own branch, started from the branch of the previous issue, and its own pull request (PR) whose
base is that previous branch:

```
main ← issue-30-<slug> ← issue-31-<slug> ← issue-32-<slug>
        PR base: main     PR base: issue-30   PR base: issue-31
```

Because each PR is compared with the previous branch, it shows only the changes of its own issue. You review them one by
one.

## Repository settings

Two settings of the repository (Settings → General → Pull Requests) matter:

- **Allow merge commits** must be on.
- **Automatically delete head branches** should be on. When it is on, GitHub deletes the branch of a merged PR and
  changes the base of the next PR to `main`. Check and switch it on from a terminal:

  ```bash
  gh api repos/<owner>/<repo> -q '.delete_branch_on_merge'
  gh api -X PATCH repos/<owner>/<repo> -F delete_branch_on_merge=true
  ```

Without this setting the stack still works, but you have to do one more step by hand after each merge (see below).

## Merging the stack

1. Merge the PRs in stack order, first the one based on `main`.
2. Always choose **Create a merge commit**. Squash and rebase rewrite the commits, and the next PR would show the
   changes of the merged one again.
3. After each merge, the next PR must be based on `main` before you merge it:
   - Setting on: GitHub does this itself. Nothing to do.
   - Setting off: click **Delete branch** on the page of the merged PR on github.com. GitHub then retargets the next
     PR. Or change the base of the next PR to `main` yourself (the **Edit** button next to the PR title, or
     `gh pr edit <next> --base main`); after that the old branch can be deleted in any way.
   - If you merge the next PR while its base is still the old branch, its changes go into that branch, not into
     `main`.
4. Do not delete a merged branch on GitHub from the IDE or by `git push --delete` while the next PR is still based on
   it. GitHub may close the next PR instead of retargeting it.
5. After the last merge, pull `main` (VS Code: the sync icon next to the branch name in the status bar, or
   `git switch main && git pull`). The IDE switches to `main` after a merge but does not download the merged commits.
6. Delete the local issue branches: `git branch -d <branch>...` (it refuses a branch that is not merged).

## Pull requests and branches

A PR and its branch are separate things on GitHub:

- A PR cannot be deleted, only closed or merged.
- Closing a PR without merging keeps its branch. Its page offers a **Delete branch** button.
- "Automatically delete head branches" acts only on merged PRs, never on closed ones.
- Deleting a branch never deletes a PR. An open PR whose own branch is deleted gets closed.
- Nothing on GitHub touches the branches on your computer. You delete local branches yourself.

## If a next PR was closed by mistake

Push the merged branch again from your local copy, reopen the PR and change its base:

```bash
git push origin <merged-branch>:<merged-branch>
gh pr reopen <next>
gh pr edit <next> --base main
```

Then the pushed branch can be deleted again.
