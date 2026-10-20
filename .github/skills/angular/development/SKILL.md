---
name: angular-development
description: Rules for writing Angular code in a project with state-oriented architecture (StOP SFSM, pseudo-modules, two kinds of DI). Covers coding style, signals, change detection, layout, logging, and the architecture rules A-M, D, C, S, K with their automated checks. Use it before writing or changing components, services, controllers, contracts, barrels or sfsm.json.
metadata:
  author: vsirotin
  version: "2.1"
---

**Scope.** Sections 1–2 apply to every Angular project. Section 3 applies only to projects built with state-oriented architecture, which have a `specs/frontend-architecture/frontend-architecture.md` and a `site-map.md`. Paths and names in its examples come from the MimoAI frontend (`aia-frontend`).

# 1. Before you start

1. Read the [common-development](../../common-development/SKILL.md) and [typescript](../../typescript/SKILL.md) skills. Their rules apply here too.
2. Read the project's `site-map.md` to find the module you need. In state-oriented projects, search the modules by keyword: `grep -rn "@keywords.*#<topic>" src/app --include=index.ts`.
3. The architecture spec (`specs/frontend-architecture/frontend-architecture.md`) is authoritative. Section 3 below is its short form. If they disagree, the spec wins; report the difference.
4. When you are done, run the project's lint (e.g. `npm run lint`, in state-oriented projects including the architecture checks) and the full test suite. Both must pass.
5. To review code, use the [angular-review](../review/SKILL.md) skill.

# 2. Angular coding style

Follow the **[Angular coding style guide](https://angular.dev/style-guide)**. In short:

- **Naming:** hyphenated file names; file name matches the primary class; shared base name for a component's `.ts`, `.html` and `.scss`; tests end in `.spec.ts`.
- **Structure:** organize by feature area, not by type. One concept per file; split files beyond about 400 lines.
- **Class member order:** Angular-specific members (injected dependencies, inputs, outputs, queries) before methods.
- **Components:** presentation logic only; no complex template expressions (use `computed()`); `protected` for template-only members; `readonly` for Angular-initialized properties; `[class]`/`[style]` bindings instead of `NgClass`/`NgStyle`; event handlers named after their action; lifecycle hooks delegate to named methods and implement the lifecycle interfaces.
- **Signals:** use `computed()` and `linkedSignal()` for derived state. Use `effect()` only for side effects towards non-signal APIs, never to copy state between signals. `effect()` needs an injection context, so it exists only in UI code.
- **Change detection:** `ChangeDetectionStrategy.OnPush` everywhere. Never mutate an input object; replace the reference.

## 2.1 Page layout and vertical scrolling

A recurring bug: pages that cannot scroll because the height chain is broken.

- A component host is `display: inline` by default. A component whose template needs block or flex layout declares `:host { display: block; }` or, for page shells, `:host { display: flex; flex-direction: column; height: 100%; }`.
- Every ancestor between the viewport and the scrolling content passes a definite height (`height: 100%`, or `flex: 1` with `min-height: 0`). Exactly ONE element owns `overflow-y: auto`. The others do not clip.
- Do not put `min-height: 0` on every flex child; it lets content be crushed instead of scrolled. Give flexible areas a usable `min-height` in px.
- After layout changes, test at 375×667 (iPhone SE) and confirm that the last element can be reached by scrolling.

## 2.2 Logging (`@vsirotin/log4ts`)

- One logger per class, as a field: `LoggerFactory.getLogger('<user-domain>.<project>.app/<module>/<Class>')`, e.g. `'eu.sirotin.mimoai.app/audio/MediaFacadeService'`.
- Use `error`, `warn`, `log`, `debug` like the `console` functions. No `console.*`.
- Levels: 0 everything, 1 error/warn/log, 2 error/warn (default), 3 error only, ≥4 silent. Change levels only in dedicated settings code.

# 3. Architecture rules

Each rule has an ID that reviews and plans refer to. *(lint)* means `npm run lint` enforces it; the others are checked in review.

## M — Modules and directories

- **M1** Every level-1 directory under `src/app` (and each declared sub-module such as `ai/gemini`) is a pseudo-module: an `index.ts` barrel plus an `@alias`. A new module needs the alias in `tsconfig.json` `paths`, `vitest.config.ts` `resolve.alias`, `MODULES` in `eslint.config.mjs`, and a row in `site-map.md`. *(lint: alias sync)*
- **M2** Inside a module, files use relative imports. Outside it, code imports only `@alias`, never a deep path. This also holds for tests in `test/`. Data files (`*.json`) are exempt. *(lint)*
- **M3** The barrel exports only names that another module uses now. Its doc comment has `@keywords` with 1–3 keywords from the `site-map.md` vocabulary. *(keywords: lint)*
- **M4** The module graph is acyclic at the interface level: an edge is a call through a Callee/Notifier/Updater/DataProvider. `import type` and calls to `@category storage` objects create no edge. `npm run lint` (`scripts/check-module-cycles.mjs`) rejects cycles of run-time imports between modules.
- **M5** The composition root (`src/app/app.ts`) is the only file that may import every module. It registers controllers with the SFSM and makes registration calls that break cycles.
- **M6** A structural change (new or moved module, directory or main file) updates `site-map.md` in the same change.

## D — Dependency injection and instances

- **D1** Angular DI (`@Injectable`, `inject()`, `provide*`) is used only in `src/app/ui` and the Angular root files (`main.ts`, `app.ts`, `app.config.ts`). *(lint)*
- **D2** No project-defined `InjectionToken`, anywhere, including UI. *(lint)*
- **D3** A non-UI class is a plain class. Its file exports one shared instance: `export const mediaFacade = new MediaFacadeService();`. The barrel exports the instance (and the class only if tests outside the module construct it). Collaborators are constructor parameters whose defaults are the partners' shared instances, so tests pass doubles: `constructor(private readonly media: IMediaControlCallee = mediaFacade) {}`.
- **D4** Each class is created in exactly one way: shared instance, `new` in tests, or Angular DI for UI classes. Never mixed.
- **D5** A UI component binds a non-UI partner as a field typed by the contract: `private readonly farewell: IFarewellNotifier = eventProcessorUI;`. Tests replace it with `vi.spyOn(eventProcessorUI, 'farewellAnimationCompleted')` and `vi.restoreAllMocks()` in `afterEach`.

## C — Contracts and communication

- **C1** Code talks to another module only through `I<Partner>Callee`, `I<Partner>Notifier`, `I<What>Updater` or `I<What>DataProvider`. A field holding a partner has the interface type, never the class type.
- **C2** A **Notifier** reports that something happened: Observables or methods returning `void`. A **Callee** is asked to do something and may return a value or Promise. Anything awaited is a Callee. Notifiers extend `INotifier`, Callees extend `ICallee`. *(lint)*
- **C3** A UI component never calls a resource to do work and wait for the outcome. If the action belongs to the application state, the round trip is: component → its Notifier → Event Processor → SFSM signal → command → Transceiver → resource → result signal → command → `TransceiverUI` → the component's Updater. If the action is independent of the application state and must not disturb it, the component registers with the resource and notifies it through an Observable; the resource answers through the component's Callee (spec rule 12). Example: the feedback panel registers with `appServerConnectionManager` (`IFeedbackDataProvider`), emits `feedbackReady$` (`IFeedbackNotifier`), and receives `showFeedbackResult(ok)` (`IFeedbackCallee`). The promocode-buying page does the same with `paypalCheckout` (`IPromocodeBuyingDataProvider`, `purchaseRequested$`, `IPromocodeBuyingUpdater`), because the PayPal SDK callbacks expect Promises.
- **C4** A partial turn without the SFSM is allowed only when the application state does not change (e.g. showing "AI is thinking" inside one state). Then a controller may call the UI controller directly, through its Callee.
- **C5** A cycle is broken by a Notifier the other side subscribes to, or by a registration method (`set<What>Updater(updater)`). Never by a token.
- **C6** Contract interfaces are named `I<Focus><SecondFocus?><Kind>` (`IFeedbackNotifier`, `IAppServerConnectionManagerCallee`). Pure data shapes may omit the `I` (`ChatMessage`). A contract used by one implementer and one consumer lives in the implementer's module; a contract shared more widely lives in `@shared`.

## S — State machine

- **S1** A behaviour change is a change in `sfsm.json` plus the matching controller method. Components and services do not get new control flow for it.
- **S2** A row is `[fromState, "<Sender>>Signal", toState, "<Receiver>.command"]`. Sender and receiver prefixes are the controller abbreviations listed in `site-map.md`.
- **S3** Only controllers registered in the composition root send signals. Pages and services never call `sendSignal`, the hub or the SFSM.
- **S4** For SFSM modelling use the `state-oriented-programming/*` skills if the project has them.

## K — Categories

- **K1** A controller extends `TransceiverBase` (Transceiver) or `SignalSenderBase` (Event Processor) from `@vsirotin/ts-stop`.
- **K2** Every class with a shared instance outside `src/app/ui` is a controller (K1, no `@category`) or has exactly one TSDoc tag `@category` with the value `ui-resource-manager` (only in `src/app/ui-controller`), `resource-manager`, `resource` or `storage`. A storage implements an interface extending `IStorage`. *(lint: A4, A7)*
- **K3** A resource manager is what controllers and UI components talk to; a resource is reached only through a resource manager. UI code imports no shared instance of a `@category resource`. *(lint: A8)* The mapping of the categories to the spec is the table in "Dependency directions".
