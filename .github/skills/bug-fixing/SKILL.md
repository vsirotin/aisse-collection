---
name: bug-fixing
description: TDD-based workflow for fixing bugs and defects. Use when investigating, reproducing, and resolving reported issues or unexpected behavior.
metadata:
  author: vsirotin
  version: "1.1"
---

# Bug-Fixing Workflow (TDD)

> **Note:** This skill is based on [common-development](../common-development/SKILL.md). Read the origin document first for complete development rules.

## Workflow

When fixing a bug, always follow this order:

1. **Write a failing unit test** — Create a test that **fails** because of the bug.

2. **Confirm the test fails** — Run the test to verify it fails, ensuring the test correctly captures the defect.

3. **Fix the code** — Implement the minimal fix to resolve the bug.

4. **Confirm the test passes** — Run the test to verify it passes. Small adjustments to the implementation or test may be needed, but reducing the number of tests or skipping them should be done only after careful consideration of the consequences.

5. **Review the whole updated file** — After each bug fix, perform a code review of the WHOLE file(s) you touched, not only the changed lines — apply the whole-file rules W1–W4 of the `angular-review` skill ([review-rules-whole-file.md](../angular/review/review-rules-whole-file.md)) (header/class doc actual + compact + self-explaining, no duplicate/stale comment blocks, naming, no leftover references). Bugs cluster in files whose documentation drifted away from the code.

6. **Report the result** — Document the fix.

## Additional Rules

These rules from common-development also apply:

- Stop if the bug fix requires more than 20 iterations (see rule 12)
- Follow consistent coding style (see rule 4)
- Include logging in important functions (see rule 3)
- Ensure the bug fix doesn't break existing tests — all unit tests in the project must pass (see rule 9)
