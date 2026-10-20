# Review rules: state machine (`sfsm.json` and controller methods)

| Rule | Check |
|------|-------|
| S1 | The behaviour change is expressed as rows in `sfsm.json` plus controller methods. No new flow logic (if-chains deciding the next step) in components or services. |
| S2 | Each row is `[fromState, "<Sender>>Signal", toState, "<Receiver>.command"]` or a three-element row without a command. The sender prefix is the controller that sends the signal, the receiver prefix the controller that handles the command. |
| S2 | Every command in `sfsm.json` has a `case` in the receiver's `handleCommand`; every `sendSignal("X>...")` string appears in `sfsm.json`. Check both directions with grep. |
| S3 | Signals are sent only by registered controllers. |
| — | A command handler that starts asynchronous work sends exactly one result signal on every path, including errors. |
| — | State names follow the existing prefix convention of their sub-machine (`IS:`, `PB:`, `PE:`, `PC:`), and end states start with `E_`. |
| — | `test/sfsm-behaviour/` golden files are regenerated and reviewed when transitions change. |

Use the `state-oriented-programming/*` skills for modelling questions.
