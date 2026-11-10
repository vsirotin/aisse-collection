# Security audit: method

The method of the skills `security-audit/web-client` and `security-audit/node-server`. An audit covers one project
and answers one question: what can an attacker do here, and how do we know?

## Rules

- Never write the value of a secret into a report, an issue, a log or the conversation. Name the file and the kind of
  secret, or mask the value.
- Details of a finding stay private until it is fixed. Never write them to a public repository or issue.
- The audit reads. It does not change data, does not attack a deployed system, and does not send test traffic to a
  third party. A check that needs more than reading runs locally, against an emulator or a test environment.
- Every statement rests on evidence that was seen in this audit. What could not be checked is reported as not checked.

## Steps

1. **Scope.** Name the project, the version and the commit. List what the project exposes: entry points, data it
   stores, secrets it uses, services it calls, money it moves. Read the project checklist, which the `CLAUDE.md` of the
   project names.
2. **Tools.** Run the dependency audit (`npm audit`, separately for production dependencies with `--omit=dev`) and a
   secret scan of the git history (`gitleaks git <repo> --redact`). Judge each match: a match of a tool is a lead, not
   a finding.
3. **Checklist.** Go through the checklist of the skill, then the project checklist. Each item gets one result:
   - `pass`, with the evidence: file and line, or the setting that was checked
   - `fail`, which becomes a candidate finding
   - `not applicable`, with the reason
   - `not checked`, with the reason
4. **Open pass.** Search for what the checklists do not name. Follow each entry point to the places where it changes
   data or spends money. Ask what happens with a repeated, a reordered or an interrupted request, and with an input of
   another user. Add what the search teaches to the project checklist.
5. **Verification.** Confirm each candidate finding in the code, and write a concrete attack scenario: who, with which
   input, reaches what. A candidate without a scenario is reported as a question, not as a finding.
6. **Report.** Write it to the private place that the project names, with the scope, the results of the tools, the
   result of each checklist item, and the findings ordered by severity. Create one issue per confirmed finding in a
   private tracker.

## Severity

| Severity | Meaning |
|---|---|
| Critical | Without any account: access to data of others, secrets or money, or running code on the server |
| High | With an ordinary account: the same, or lasting damage for other users |
| Moderate | Needs unusual conditions, or the damage is limited, such as a short denial of service |
| Low | Makes other attacks easier, without direct damage |

An automatic finding of a dependency keeps its published severity until the audit has checked whether the affected code
is reached. An audit by an AI agent does not replace a penetration test by a specialist.
