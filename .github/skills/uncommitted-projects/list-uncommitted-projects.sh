#!/usr/bin/env bash
#
# list-uncommitted-projects.sh - shows which projects of a group hold uncommitted changes (modified, staged, deleted or
# untracked files) or unpushed commits (commits of any local branch that are on no remote branch), with the changed
# files and the command that opens each project in VS Code.
#
# Groups: every file `<group>-partner-projects.txt` in the given directory or in the root of its git repository (the
# head project of a group holds the file, the other members a symlink to it). Format: one absolute project path per
# line; blank lines and lines starting with `#` are ignored.
#
# Usage: list-uncommitted-projects.sh [--markdown] [<directory>]
#   --markdown   output as Markdown (tables), for an agent's report; default is plain text
#   <directory>  where to look for the group files; default is the current directory
#
# Works with the bash 3.2 of macOS.

set -euo pipefail

MAX_FILES=20

usage() {
  sed -n '2,/^# Works/p' "$0" | sed 's/^# \{0,1\}//'
}

format="text"
start="."
while [[ $# -gt 0 ]]; do
  case "$1" in
    --markdown) format="markdown"; shift ;;
    --help|-h) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *) start="$1"; shift ;;
  esac
done

if [[ ! -d "$start" ]]; then
  echo "Not a directory: $start" >&2
  exit 1
fi
start="$(cd "$start" && pwd)"
root="$(git -C "$start" rev-parse --show-toplevel 2>/dev/null || echo "$start")"

# Group files in the directory and in its git root; a group appears once even if both hold it.
group_files=()
group_names=" "
for dir in "$start" "$root"; do
  for file in "$dir"/*-partner-projects.txt; do
    [[ -e "$file" ]] || continue
    name="$(basename "$file")"; name="${name%-partner-projects.txt}"
    [[ "$group_names" == *" $name "* ]] && continue
    group_names="$group_names$name "
    group_files+=("$file")
  done
done

if [[ ${#group_files[@]} -eq 0 ]]; then
  where="$start"
  [[ "$root" != "$start" ]] && where="$start or $root"
  echo "No file <group>-partner-projects.txt in $where." >&2
  exit 1
fi

# Status of one project, in the globals state ("missing", "clean", "dirty"), branch, uncommitted, unpushed, changes.
check_project() {
  local project="$1"
  changes=""; branch=""; uncommitted=0; unpushed=0
  if ! git -C "$project" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    state="missing"
    return
  fi
  branch="$(git -C "$project" branch --show-current)"
  branch="${branch:-(detached)}"
  changes="$(git -C "$project" status --porcelain)"
  [[ -n "$changes" ]] && uncommitted="$(printf '%s\n' "$changes" | wc -l | tr -d ' ')"
  unpushed="$(git -C "$project" log --branches --not --remotes --oneline | wc -l | tr -d ' ')"
  if [[ "$uncommitted" -eq 0 && "$unpushed" -eq 0 ]]; then state="clean"; else state="dirty"; fi
}

# The first MAX_FILES lines of the changes, each with the given prefix and suffix.
print_changes() {
  local prefix="$1" suffix="$2"
  printf '%s\n' "$changes" | head -n "$MAX_FILES" | while IFS= read -r line; do
    printf '%s%s%s\n' "$prefix" "$line" "$suffix"
  done
  if [[ "$uncommitted" -gt "$MAX_FILES" ]]; then
    echo "${prefix}... and $((uncommitted - MAX_FILES)) more"
  fi
}

total_dirty=0
for group_file in "${group_files[@]}"; do
  group="$(basename "$group_file")"; group="${group%-partner-projects.txt}"
  projects=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [[ -z "$line" || "$line" == \#* ]] && continue
    projects+=("$line")
  done < "$group_file"

  clean=""; missing=""; dirty=()
  for project in ${projects[@]+"${projects[@]}"}; do
    check_project "$project"
    case "$state" in
      missing) missing="$missing, $project" ;;
      clean) clean="$clean, $(basename "$project")" ;;
      dirty) dirty+=("$project") ;;
    esac
  done
  total_dirty=$((total_dirty + ${#dirty[@]}))

  if [[ "$format" == "markdown" ]]; then
    echo "## Group \`$group\`: ${#dirty[@]} of ${#projects[@]} projects with uncommitted or unpushed work"
    echo
    if [[ ${#dirty[@]} -gt 0 ]]; then
      echo "| Project | Branch | Uncommitted files | Unpushed commits |"
      echo "|---------|--------|-------------------|------------------|"
      for project in "${dirty[@]}"; do
        check_project "$project"
        echo "| $(basename "$project") | \`$branch\` | $uncommitted | $unpushed |"
      done
      echo
      # Per project the open command and the changed files in fenced blocks, which a viewer can copy with one click.
      for project in "${dirty[@]}"; do
        check_project "$project"
        echo "### $(basename "$project")"
        echo
        echo '```bash'
        echo "code \"$project\""
        echo '```'
        echo
        if [[ "$uncommitted" -gt 0 ]]; then
          echo '```text'
          print_changes '' ''
          echo '```'
          echo
        fi
      done
    fi
    [[ -n "$clean" ]] && echo "Clean: ${clean#, }." && echo
    [[ -n "$missing" ]] && echo "Not found or not a git repository: ${missing#, }." && echo
  else
    echo "Group $group ($group_file)"
    echo
    for project in ${dirty[@]+"${dirty[@]}"}; do
      check_project "$project"
      echo "$(basename "$project"): branch $branch, $uncommitted uncommitted file(s), $unpushed unpushed commit(s)"
      print_changes '    ' ''
      echo "  code \"$project\""
      echo
    done
    [[ -n "$clean" ]] && echo "Clean: ${clean#, }"
    [[ -n "$missing" ]] && echo "Not found or not a git repository: ${missing#, }"
    echo
  fi
done

if [[ "$format" == "text" ]]; then
  echo "Projects with uncommitted or unpushed work: $total_dirty"
fi
