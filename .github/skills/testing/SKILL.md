---
name: testing
description: Testing discipline covering coverage expectations, test naming conventions, organization, execution requirements, and cleanup. Use when writing, organizing, or running unit tests.
metadata:
  author: vsirotin
  version: "1.0"
---

# Testing Rules

> **Note:** This skill is based on [common-development](../common-development/SKILL.md). Read the origin document first for complete development rules.

## Test Coverage Expectations

If technically possible, unit tests should contain test cases for:

- **All code paths** — every branch in the tested function (decisions made with `if`, `switch`, `match`, etc.)
- **Timeout worst cases** — worst-case timeout scenarios for language constructs like `await` on internal calls
- **Broken or unavailable connections** — worst cases for unavailable or broken external connections. If mocking is not easy, consider proposing a manual test (e.g. the user manually breaks the internet connection and runs a test script). Propose this when the programming language, frameworks, and tools support it.
- **Missing or invalid environment variables** — worst cases for unavailable or wrongly-valued environment variables used internally

## Test Function Naming Convention

Use the following naming pattern for test functions:

```
test_<subject_under_test>_<aspect>
```

- `<subject_under_test>` — what is being tested (for unit tests of a single function, use the function name)
- `<aspect>` — short abbreviation for the tested aspect (up to 10 characters), e.g. `timeout`, `no_conn`, `bad_env`

## Group Unit Tests into Sub-Directories

When a project has many unit tests (more than 5), group them into sub-directories by topic or module.

## All Unit Tests Must Pass

After completing development, all unit tests in the project must pass.

## Clean Up Temporary Test Artifacts

After running tests, delete any temporary directories or files created during the test run (e.g. output or download directories produced in `dist/` by integration tests). Leave the project tree in the same state it was before the tests ran.

## Related Rules

These rules from common-development also apply:

- Tests for features must be developed before or alongside production code (see feature-development skill)
- Tests for bugs must be written to fail before fixing (see bug-fixing skill)
- Follow consistent coding style (see rule 4)
