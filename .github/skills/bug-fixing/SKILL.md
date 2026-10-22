---
name: bug-fixing
description: TDD-based workflow for fixing bugs and defects. Use when investigating, reproducing, and resolving reported issues or unexpected behavior.
metadata:
  author: vsirotin
  version: "1.3"
---

# Bug-Fixing Workflow (TDD)

> **Note:** This skill is based on [common-development](../common-development/SKILL.md). Read the origin document first for complete development rules.

## Workflow

When fixing a bug, always follow this order:

1. **Write a failing unit test** — Create a test that **fails** because of the bug.

2. **Confirm the test fails** — Run the test to verify it fails, ensuring the test correctly captures the defect.

3. **Fix the code** — Implement the minimal fix to resolve the bug.

4. **Confirm the test passes** — Run the test to verify it passes. Small adjustments to the implementation or test may be needed, but reducing the number of tests or skipping them should be done only after careful consideration of the consequences.

5. **Review the whole updated file** — After each bug fix, review the WHOLE file(s) you touched, not only the changed lines (common-development §2.7). If the project has a review skill with whole-file rules, apply them too. Bugs cluster in files whose documentation drifted away from the code.

6. **Check the partner projects** — If the project documents partner projects (a "Partner projects" section in its site map, see common-development §1.1), check whether the bug belongs in the integration tests of a partner test project. It does only if
   - it arises from the interplay with a partner project,
   - the unit tests of this project cannot catch it, and
   - no existing integration test covers it.

   Prefer extending an existing integration test to adding a new one. If the bug qualifies, find its place in the test structure of that project (its test catalog or category layout) and propose the entry to the user in the report. Do not change the partner project without the user's consent; when changing it, follow its own rules.

7. **Report the result** — Document the fix, including the proposal of step 6 if there is one. If issues were created or updated (see "Bugs across several projects"), list them as links so the user can open them in the browser or the IDE.

## Bugs across several projects

When the cause or the fix of a bug spans this project and its partner projects (common-development §1.1), and the projects use an issue tracker (for example GitHub issues through the `gh` CLI), track the work there:

1. **Agree on the procedure first.** Ask the user once per task how the issues are closed: by commits that reference them, by a comment, or left open for the user. Never commit or close an issue on your own.
2. **Root issue in the leading project.** Create one root issue in the project that owns the rule or the interface the fix depends on (often the server or the library whose contract changes). It holds the evidence (logs, data), the decisions of the user and the task list of that project.
3. **Dependent issues in the partner projects.** One issue per partner project that has to change, including the test project when the bug qualifies for integration tests (step 6). Each refers to the root issue, describes only its own part and has its own task list.
4. **Link them in the tracker, not only in the text.** Make the dependent issues sub-issues of the root issue, and add a "blocked by" dependency on the issues whose results they need. Links across repositories of the same owner work. On GitHub both are set through the REST API, which takes the numeric issue id, not the issue number.
5. **Work in dependency order.** First the leading project (it provides the contract), then the projects that use it, the test project last. If a partner project has unfinished or uncommitted work, ask the user before starting there.
6. **Keep the issues current.** Reference the issue in the release notes and the commit text (`Refs <owner>/<repo>#<n>`; a closing keyword only if the user wants issues closed by commits). When a project's part is done, tick its task list and add a comment with the version, the checks that ran and what is left.

Practical hints: check the login and the labels of each repository before creating issues; write long issue texts to a temporary file and pass the file (avoids shell quoting problems with backticks and `$`).

## Additional Rules

These rules from common-development also apply:

- Stop if the bug fix requires more than 20 iterations (see §2.6)
- Follow consistent coding style (see §2.2)
- Include logging in important functions (see §2.1)
- Ensure the bug fix doesn't break existing tests — all unit tests in the project must pass (see the [testing](../testing/SKILL.md) skill)
