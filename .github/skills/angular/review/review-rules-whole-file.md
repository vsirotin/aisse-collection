# Review rules: whole file (every changed file)

The agent that changes a file is responsible for the whole file, not only the changed lines.

- **W1 Whole file reviewed.** Header and class doc, comments, structure and naming are consistent with the current code. No dead or duplicated comment blocks, no stale TODOs. Important files (controllers, resource managers) have a short, current header that explains the class to humans and agents.
- **W2 Self-contained docs.** Docs do not refer to volatile things (plans, issues, release notes, "Step 3", "ex bar-2"). Only architecture documents may be referenced. What a class does NOT do belongs in specs, not in the class doc.
- **W3 Renames are complete.** After a rename or move, `grep -rn '<OldName>' src/ test/ specs/ site-map.md` finds nothing unexplained: imports, comments, specs, docs.
- **W4 Comments describe the present.** No history ("was moved from", "no longer injected", "REVERTED"). History is in git and the release notes.

How to check W3 and W4 quickly:

```bash
grep -rnE "ex bar-|formerly|no longer|was moved|REDO|Step [0-9]" <changed files>
```
