---
name: bug-fixing
description: TDD-based workflow for fixing bugs and defects. Use when investigating, reproducing, and resolving reported issues or unexpected behavior.
metadata:
  author: vsirotin
  version: "1.2"
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

7. **Report the result** — Document the fix, including the proposal of step 6 if there is one.

## Additional Rules

These rules from common-development also apply:

- Stop if the bug fix requires more than 20 iterations (see §2.6)
- Follow consistent coding style (see §2.2)
- Include logging in important functions (see §2.1)
- Ensure the bug fix doesn't break existing tests — all unit tests in the project must pass (see the [testing](../testing/SKILL.md) skill)
