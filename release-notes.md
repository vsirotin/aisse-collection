# Release notes

## Version: 0.1.8 build 11
doc: bug-fixing 1.4 and feature-development 1.2: the agent closes an issue itself as soon as it is complete (task list done, all checks pass, work committed) with a comment naming the version, the commit and the checks; issues with open items stay open, a root issue is closed after its sub-issues; a procedure the user asks for in a task wins. Replaces "ask the user once per task how issues are closed".

## Version: 0.1.7 build 10
doc: bug-fixing 1.3: new section "Bugs across several projects": agree with the user how issues are closed, a root issue in the leading project (owner of the rule or interface), dependent issues in the partner projects including the test project, linked in the tracker as sub-issues and "blocked by" dependencies, work in dependency order, keep the issues current (references in release notes and commit texts, ticked task lists, progress comments); step 7 reports the issues as links. Learned from the first cross-project bug tracked with GitHub issues (aia-server, aia-frontend, aia-test).

## Version: 0.1.6 build 9
doc: Skills made generic: bug-fixing step 6 checks partner projects for integration-test candidates; common-development defines the "Partner projects" site-map section (§1.1) and whole-file responsibility (§2.7); post-task semver examples, carrier lookup and commit step corrected; project-specific paths removed from typescript and angular skills; stale rule references fixed. 

## Version: 0.1.5 build 8
doc: Skills updated: angular, common-development, typescript. 

## Version: 0.1.4 build 7
doc: Post-task updated.

## Version: 0.1.3 build 6
doc: Post-task, Angular and TypeScript skills updated.

## Version: 0.1.2 build 5
doc: Post-task and rest.API skills updated.

## Version: 0.1.1 build 4
doc:Added symlink-skills.sh script.

## Version: 0.1.1 build 3
doc:Added Angular and TypeScript skills.

## Version: 0.1.0 build 2
doc: Extracted feature-development, bug-fixing, and testing skills from common-development skill.

## Version: 0.0.1 build 1
Initial commit
