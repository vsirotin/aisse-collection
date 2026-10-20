# Review rules: directories and barrels

Applies to new, moved or deleted directories, every `index.ts`, and the files that declare modules.

| Rule | Check |
|------|-------|
| M1 | A new pseudo-module has `index.ts`, an alias in `tsconfig.json`, `vitest.config.ts`, `eslint.config.mjs` `MODULES`, and a row in `site-map.md`. *(alias sync: lint)* |
| M1 | A new test directory under `test/` is covered by the `include` globs in `angular.json` and `tsconfig.spec.json`. |
| M3 | Each exported name of the barrel is used outside the module: `grep -rn "<Name>" src test --include=*.ts \| grep -v "src/app/<dir>/"`. Unused exports are removed. |
| M3 | The barrel doc has `@keywords` (1–3, from the `site-map.md` vocabulary). A new keyword is added to `site-map.md` first. *(lint)* |
| M3 | The barrel re-exports only from its own module. A re-export of another module's names (`export type { X } from '@other'`) is a Major: consumers must import from the owner. |
| M4 | New `import` lines between modules do not close a cycle at the interface level. Run-time import cycles fail `npm run lint`; for edges through storage calls, draw the edge list of the touched modules if unsure. |
| M6 | `site-map.md` matches the directories after the change: new and moved directories appear, deleted ones are gone. |
| — | A directory inside a module is named after its feature, not after a file type (`pages/feedback/`, not `services/`). |
