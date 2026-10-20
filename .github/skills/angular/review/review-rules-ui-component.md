# Review rules: UI components (`src/app/ui`)

UI code may use Angular DI for Angular's own services (`Router`, `MatDialog`, `MAT_DIALOG_DATA`) and for `@Injectable` services inside `src/app/ui`. Everything else follows the production rules.

| Rule | Check |
|------|-------|
| D2 | No `InjectionToken` is defined or injected for a project contract. *(lint for definitions)* |
| D5 | A non-UI partner is a field typed by its contract and set to the partner's shared instance: `private readonly x: IXxxNotifier = xxx;`. |
| C3 | The component does not call a resource or a non-UI service to do work (send, buy, save remotely, connect) and does not `await` a result from another module. It notifies its Notifier and receives the outcome through its Updater. Look for `await` and `.then(` on fields typed by another module's contract. |
| C3 | The component does not decide application flow (which view comes next, whether a session starts). That is a state in `sfsm.json`. |
| C1 | Reading and writing `@category storage` objects (e.g. the session context) directly is allowed. |
| U1 | The host declares its layout: `:host { display: ... }` in the component stylesheet. |
| U2 | In the height chain from the viewport to scrolling content, exactly one element has `overflow-y: auto`; no `min-height: 0` on every flex child. |
| U3 | `ChangeDetectionStrategy.OnPush`; template-only members are `protected`; derived state is `computed()`; no `effect()` copying signals. |
| — | Localized texts come from a `public/assets/languages/...` JSON with a default object in the component; new keys exist in all supported languages. |
| — | A component that registers itself with a DataProvider unregisters in `ngOnDestroy`. |
