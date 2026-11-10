---
name: uncommitted-projects
description: Report which projects of the current project's group(s) hold uncommitted changes or unpushed commits, as Markdown with the changed files and the command that opens each project in VS Code. Use when the user asks what is not committed or pushed, what is still open in the partner projects, or before ending a working session.
metadata:
  author: vsirotin
  version: "1.0"
---

# Uncommitted projects

A group of projects that are developed together is listed in a file `<group>-partner-projects.txt` in the root of its
head project: one absolute project path per line (the head project itself included), blank lines and `#` comments
ignored. The other members hold a symlink to this file in their root (not in git). Common projects that serve many
groups, such as this skill collection, are listed but hold no file. A project may belong to several groups.

## Steps

1. Run the script of this skill from the project's directory:
   `bash .github/skills/uncommitted-projects/list-uncommitted-projects.sh --markdown`
   (the path of the skill directory may differ in the project; the script is next to this file). It finds the group
   files in the current directory and in the root of its git repository.
2. If it reports that no group file exists, tell the user and stop. Do not guess the members of a group.
3. Report its output as it is: per group a table of the projects with uncommitted files or unpushed commits (branch,
   counts, the `code "<path>"` command that opens the project in VS Code), the changed files of each, and the clean
   projects. Add nothing that is not in the output.
4. Do not commit, push or change anything. If the user asks to open a project, run its `code "<path>"` command.

A person can run the script directly in a terminal; without `--markdown` it prints plain text.
