---
name: feature-development
description: Workflow for implementing new features and processing issues. Use when adding new functionality, implementing requirements, or processing feature requests.
metadata:
  author: vsirotin
  version: "1.0"
---

# Feature Development and Issue Processing Workflow

> **Note:** This skill is based on [common-development](../common-development/SKILL.md). Read the origin document first for complete development rules.

## Workflow

When implementing a new feature or processing a feature request, always follow this order:

1. **Design interfaces** — Develop interfaces or empty classes with function signatures to decide on the API. Within the same sub-project this can be interfaces in the used programming language (e.g. TypeScript). Between sub-projects it can be interfaces in the corresponding sub-protocol (e.g. OpenAPI specification).

2. **Write tests first** — Develop tests of all types according to sub-project requirements. All projects with code require unit tests; in some cases also behaviour and integration tests. Tests must be developed before or alongside the implementation of production code.

3. **Implement production code** — Develop the production code following the designed interfaces.

4. **Run tests to confirm they pass** — Execute the full test suite. Small adjustments to implementation or tests may be needed to align details, but reducing the number of tests or skipping them is an exception and should be done only after careful consideration of the consequences.

5. **Report the result** — Document the outcome.

## Additional Rules

These rules from common-development also apply:

- All unit tests in the project must pass after completing development (see rule 9)
- Follow consistent coding style across the project (see rule 4)
- Document any environment dependencies used by new functions (see rule 5)
