---
name: angular
description: Common rules for Angular code development. These guidelines apply to components, services, modules, dependency injection, and reactive patterns.
metadata:
  author: vsirotin
  version: "1.4"
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
