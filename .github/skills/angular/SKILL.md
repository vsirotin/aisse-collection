---
name: angular
description: Common rules for Angular code development. These guidelines apply to components, services, modules, dependency injection, and reactive patterns.
metadata:
  author: vsirotin
  version: "1.7"
---

# 1. Dependencies

Read first the [common-development](../common-development/SKILL.md) and [typescript](../typescript/SKILL.md) skills, as they contain rules that apply to Angular development as well.

# 2Coding Style

Follow the **[Angular coding style guide](https://angular.dev/style-guide)** as the primary reference for Angular-specific conventions. The key areas it covers:

- **Naming:** hyphenated file names; file name matches the primary class; shared base name for component `.ts`, `.html`, and `.css`/`.scss` files; `.spec.ts` suffix for tests.
- **Type suffixes:** use conventional suffixes — `.component`, `.service`, `.directive`, `.pipe`, `.guard`, `.resolver`.
- **Project structure:** all UI code under `src/`; bootstrap in `src/main.ts`; organize by **feature area** (not by type such as `components/`, `services/`); group related files in the same directory.
- **One concept per file:** one component, directive, or service per file. Split files that grow beyond approximately 400 lines.
- **Dependency injection:** use the `inject()` function rather than constructor parameter injection.
- **Class member order:** group Angular-specific properties (injected dependencies, inputs, outputs, queries) before methods.
- **Components and directives:** keep presentation logic only; avoid complex expressions in templates (extract to `computed()`); use `protected` for template-only members; mark Angular-initialized properties `readonly`; prefer `[class]`/`[style]` bindings over `NgClass`/`NgStyle`; name event handlers after their action; keep lifecycle hooks simple by delegating to named methods; implement lifecycle interfaces (`OnInit`, `OnDestroy`, etc.).

---

## 2.2 Signals

- Prefer `computed()` and `linkedSignal()` for all derived state.
- Use `effect()` only for side effects and for syncing to non-signal APIs (e.g. writing to `localStorage`, calling a third-party imperative API).
- Never use `effect()` to propagate state between signals — use `computed()` instead.

---

## 2.3 Change Detection and Performance

- Use `ChangeDetectionStrategy.OnPush` by default on all components.
- Never mutate an input object directly. Change the reference so that OnPush detects the change. Call `ChangeDetectorRef.markForCheck()` only when mutation cannot be avoided.
- Run non-UI work outside the Angular zone using `NgZone.runOutsideAngular()` to avoid unnecessary change detection cycles.

---

## 2.4 Test Organization

Unit tests follow the testing skill; additionally:

- **Isolated unit tests** (one class under test) are co-located with the class as `<name>.spec.ts`.
- **Local integration tests** ("cross-class" tests exercising the collaboration of several real classes with mocks/stubs at their boundaries) are NOT placed next to a single class. Group them in a dedicated top-level `test/<topic>/` directory of the project, one sub-directory per topic/feature, with shared fixtures in a local `fixtures.ts` (or `test-data.ts`).
- These directories must be registered in the test builder configuration (`include` globs) and in the spec TypeScript config so both the IDE and the test runner discover them.
- Prefer instantiating the real collaborating classes and stubbing only external boundaries (network, storage, time, browser location) over mocking every internal collaborator. Mock stateful singletons between tests (reset them in `beforeEach`).
- Keep such tests hermetic: no real network access, no dependence on other placeholder implementations that may send unexpected responses.

---

## 2.5 Page Layout and Vertical Scrolling

Recurring bug class in this project (fixed twice: commit `2fcd0f1` and v0.24.11): pages were not vertically scrollable because the flex/overflow height chain was silently broken. Rules:

- **Angular component hosts are `display: inline` by default.** A component whose template assumes block/flex layout MUST declare its host layout explicitly, e.g. `:host { display: block; }` (simple pages) or `:host { display: flex; flex-direction: column; height: 100%; }` (page shells). An inline host breaks `height: 100%` of its children and makes child `flex: 1` rules ineffective.
- **Scroll chain:** every ancestor between the viewport and the scrollable content must propagate a definite height (`height: 100%` / `flex: 1` + `min-height: 0`) and exactly ONE element in the chain must own the scrolling (`overflow-y: auto`). Elements that only pass height through must not clip (`overflow: hidden`) unless they are the intended scroll container.
- **Do not put `min-height: 0` on every flex child by default.** It allows the item to shrink below its content size, silently absorbing overflow — the page then "fits" the viewport with crushed content and nothing can scroll. Set `min-height: 0` only where internal scrolling is intended, and give flexible page areas a usable `min-height` (e.g. px) so short viewports (iPhone SE) overflow and scroll instead of squeezing content away.
- **Verification:** after layout changes, test at a small viewport (e.g. iPhone SE 375×667) and confirm the bottom-most element is reachable by scrolling. A quick isolation technique: temporarily hide the real content and add many placeholder paragraphs (`<p>X0</p>…`) to see where scrolling breaks.

---

## 2.6 Logging (@vsirotin/log4ts)

Use the `@vsirotin/log4ts` library instead of `console.*` for all runtime logging:

- **Logger creation:** one logger per class, created as a class field with a stable identifier equal to the source path of the class, **prefixed with `<user-domain>.<project-name>.`**:
  ```typescript
  import { LoggerFactory } from '@vsirotin/log4ts';

  private readonly logger = LoggerFactory.getLogger(
    'eu.sirotin.mimoai.app/core/services/MyService',
  );
  ```
  The prefix (`<user-domain>.<project-name>.`, e.g. `eu.sirotin.mimoai.`) enables filtering application logs from logs of used libraries and components.
- **Call sites:** use the logger members `error`, `warn`, `log` and `debug` exactly like the corresponding `console` functions (`this.logger.error(...)`, `this.logger.debug(...)`).
- **Levels:** 0 — output everything; 1 — error/warn/log; 2 — error/warn (default); 3 — error only; ≥4 — silent. Choose the level per message importance: unexpected but handled problems → `warn`; failures requiring attention → `error`; normal operational events → `log`; detailed diagnostics → `debug`.
- **Dynamic control:** logging is controlled at runtime via `LoggerFactory.setLogLevelsByAllLoggers(level)` or `LoggerFactory.setLogLevel(pattern, level)` where `pattern` supports leading/trailing `*` wildcards matched against logger identifiers. Never hard-code level changes in production code except in dedicated configuration/settings components.

