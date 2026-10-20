# Review rules: tests (`*.spec.ts`, `test/**`)

| Rule | Check |
|------|-------|
| T1 | A unit test (one class under test) sits next to the class as `<name>.spec.ts`. A test that combines several real classes lives in `test/<topic>/` with a shared `fixtures.ts`. |
| T2 | Tests outside a module import it only through its alias (M2, *lint*). Tests inside a module may use relative imports. |
| T3 | Non-UI classes are tested without `TestBed`: construct the class with test doubles as constructor arguments, or spy on shared instances. `TestBed` is for components only. |
| T4 | A spy on a shared instance (`vi.spyOn(sharedInstance, ...)`) is restored in `afterEach` (`vi.restoreAllMocks()`). Shared singletons whose state the test changes are reset in `beforeEach`. |
| T5 | Tests are hermetic: no real network, no real timers where fake timers fit, no dependence on test order. |
| T6 | Test names state the expected behaviour; assertions check behaviour (signals sent, partner calls, rendered output), not private fields. |
| — | A bug fix comes with a test that failed before the fix (see the bug-fixing skill). |
| — | No unused imports or variables in tests. *(lint)* |
