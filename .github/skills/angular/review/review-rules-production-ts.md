# Review rules: production TypeScript (outside `src/app/ui`)

| Rule | Check | How |
|------|-------|-----|
| D1, D2 | No `@Injectable`, `inject()`, `provide*`, `InjectionToken`. | lint |
| D3 | The class is plain; its file exports one shared instance; collaborators are constructor parameters typed by their contract, with the partners' shared instances as defaults. | read the constructor |
| D4 | The class is not also created elsewhere: `grep -rn "new <Class>(" src` finds only its own file (and specs). | grep |
| C1 | Fields that hold a partner from another module have an interface type (`IXxxCallee`, `IXxxNotifier`), not the class type. Calls to another module go through such a field, not through `import { someInstance }` used inline. | read fields and calls |
| C2 | A new or changed `I*Notifier` has only Observables or `void` methods and extends `INotifier`; an `I*Callee` extends `ICallee`. | lint |
| C5 | No new mutual dependency between two modules. A needed back-channel is a Notifier subscription or a `set<What>Updater` registration. | read imports of both modules |
| C6 | Contract naming and placement as in the development skill. | read |
| S3 | `sendSignal` appears only in classes extending `TransceiverBase` or `SignalSenderBase`: `grep -rn "sendSignal" src/app --include=*.ts`. | grep |
| K1 | A class that sends signals or receives commands extends one of the two base classes and is registered in the composition root (M5). | grep `registerTransceiver\|registerSignalSender` |
| K2 | A class with a shared instance is a controller or has exactly one `@category` (`ui-resource-manager`, `resource-manager`, `resource`, `storage`) that matches its role. A storage implements an interface extending `IStorage`. | lint (A4, A7); read the class doc for the role |
| K3 | Controllers and UI components talk to resource managers, not to resources; a resource depends only on storage, `@shared` and `@utils`. | lint (A8, UI side); read imports |
| — | Logging: functions longer than about 10 lines, and important short ones, log on entry and around external calls and decisions. The logger id follows `<domain>.<project>.app/<module>/<Class>`. | read |
| — | Radical simplicity: no unused exports, no signals without a consumer, no API for future steps, unused parameters prefixed with `_`. | read |
