#!/bin/bash
#
# symlink-skills.sh
#
# This script creates symlinks from a target project's `.github/skills` directory
# to the skills available in the current repository's `.github/skills` directory.
#
# Usage:
#   ./scripts/symlink-skills.sh --target-project <absolute-path>
#   ./scripts/symlink-skills.sh --help
#
# Example:
#   ./scripts/symlink-skills.sh --target-project /Users/vsirotin/VSCodeProjects/app-server
#

set -euo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SOURCE_SKILLS_DIR="${REPO_ROOT}/.github/skills"

# Colors for output (if terminal supports it)
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly YELLOW='\033[1;33m'
    readonly GREEN='\033[0;32m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly YELLOW=''
    readonly GREEN=''
    readonly BLUE=''
    readonly NC=''
fi

# Global variables
TARGET_PROJECT=""
declare -a SELECTED_SKILLS=()
declare -a AVAILABLE_SKILLS=()
CREATED_COUNT=0
SKIPPED_COUNT=0

# Print usage information
show_help() {
    echo -e "${BLUE}symlink-skills.sh${NC} - Create symlinks for Claude skills into a target project"
    echo ""
    echo -e "${YELLOW}USAGE${NC}"
    echo "    $(basename "$0") [OPTIONS]"
    echo ""
    echo -e "${YELLOW}OPTIONS${NC}"
    echo "    --target-project <path>    Absolute path to the target project directory"
    echo "    --help                     Show this help message"
    echo ""
    echo -e "${YELLOW}DESCRIPTION${NC}"
    echo "    This script scans the current repository's \`.github/skills\` directory and"
    echo "    presents a list of available skills. After your selection, it creates"
    echo "    symlinks for each chosen skill inside the target project's"
    echo "    \`.github/skills\` directory."
    echo ""
    echo "    If a skill already exists in the target project, a warning is printed"
    echo "    and the existing item is left untouched."
    echo ""
    echo -e "${YELLOW}EXAMPLE${NC}"
    echo "    $(basename "$0") --target-project /Users/viktorsirotin/VSCodeProjects/aia-server"
    echo ""
    echo -e "${YELLOW}EXIT CODES${NC}"
    echo "    0   Success"
    echo "    1   Invalid arguments or missing required parameters"
    echo "    2   Target project path does not exist or is not writable"
    echo "    3   No skills found in source directory"
}


# Logging helpers
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target-project)
                if [[ -z "${2:-}" ]]; then
                    log_error "Missing value for --target-project"
                    exit 1
                fi
                TARGET_PROJECT="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help >&2
                exit 1
                ;;
        esac
    done

    if [[ -z "$TARGET_PROJECT" ]]; then
        log_error "Missing required parameter: --target-project"
        show_help >&2
        exit 1
    fi
}

# Validate that source skills directory exists and contains skills
validate_source() {
    if [[ ! -d "$SOURCE_SKILLS_DIR" ]]; then
        log_error "Source skills directory not found: $SOURCE_SKILLS_DIR"
        exit 3
    fi

    AVAILABLE_SKILLS=()
    while IFS= read -r dir; do
        AVAILABLE_SKILLS+=("$(basename "$dir")")
    done < <(find "$SOURCE_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

    if [[ ${#AVAILABLE_SKILLS[@]} -eq 0 ]]; then
        log_error "No skill directories found in $SOURCE_SKILLS_DIR"
        exit 3
    fi
}

# Validate target project path
validate_target() {
    if [[ ! -d "$TARGET_PROJECT" ]]; then
        log_error "Target project directory does not exist: $TARGET_PROJECT"
        exit 2
    fi

    if [[ ! -w "$TARGET_PROJECT" ]]; then
        log_error "Target project directory is not writable: $TARGET_PROJECT"
        exit 2
    fi
}

# Display interactive menu for skill selection
select_skills() {
    echo ""
    log_info "Available skills in ${SOURCE_SKILLS_DIR}:"
    echo ""

    local i=1
    for skill in "${AVAILABLE_SKILLS[@]}"; do
        echo "  ${i}) ${skill}"
        ((i++))
    done

    echo ""
    read -rp "Enter skill numbers to link (space-separated, e.g. '1 3 5' or 'all'): " -a selection

    # Handle 'all' shortcut
    if [[ "${selection[0]:-}" == "all" ]]; then
        SELECTED_SKILLS=("${AVAILABLE_SKILLS[@]}")
        return
    fi

    # Convert selections to skill names
    for idx in "${selection[@]}"; do
        # Validate index is a number
        if [[ "$idx" =~ ^[0-9]+$ ]]; then
            local array_index=$((idx - 1))
            if [[ $array_index -ge 0 && $array_index -lt ${#AVAILABLE_SKILLS[@]} ]]; then
                SELECTED_SKILLS+=("${AVAILABLE_SKILLS[$array_index]}")
            else
                log_warn "Skipping invalid selection: $idx"
            fi
        else
            log_warn "Skipping invalid input: $idx"
        fi
    done

    if [[ ${#SELECTED_SKILLS[@]} -eq 0 ]]; then
        log_warn "No valid skills selected. Exiting."
        exit 0
    fi
}

# Confirm selection with the user
confirm_selection() {
    echo ""
    log_info "Selected skills:"
    for skill in "${SELECTED_SKILLS[@]}"; do
        echo "  - ${skill}"
    done
    echo ""
    read -rp "Create symlinks for these skills? [Y/n] " confirm
    confirm="${confirm:-Y}"
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Aborted by user."
        exit 0
    fi
}

# Create symlinks for each selected skill
create_symlinks() {
    local target_skills_dir="${TARGET_PROJECT}/.github/skills"
    CREATED_COUNT=0
    SKIPPED_COUNT=0

    # Ensure target skills directory exists
    if [[ ! -d "$target_skills_dir" ]]; then
        mkdir -p "$target_skills_dir"
        log_info "Created target directory: $target_skills_dir"
    fi

    for skill in "${SELECTED_SKILLS[@]}"; do
        local source_path="${SOURCE_SKILLS_DIR}/${skill}"
        local target_path="${target_skills_dir}/${skill}"

        if [[ -e "$target_path" || -L "$target_path" ]]; then
            log_warn "Skipping '${skill}': target already exists at ${target_path}"
            ((SKIPPED_COUNT++))
            continue
        fi

        if ln -s "$source_path" "$target_path"; then
            log_success "Created symlink: ${skill} -> ${target_path}"
            ((CREATED_COUNT++))
        else
            log_error "Failed to create symlink for '${skill}'"
        fi
    done
}

# Print final report
print_report() {
    echo ""
    echo "========================================"
    log_info "Operation complete."
    echo "========================================"
    echo ""
    echo "  Source skills directory : ${SOURCE_SKILLS_DIR}"
    echo "  Target project          : ${TARGET_PROJECT}"
    echo "  Target skills directory : ${TARGET_PROJECT}/.github/skills"
    echo ""
    echo "  Created symlinks        : ${CREATED_COUNT}"
    echo "  Skipped (already exist) : ${SKIPPED_COUNT}"
    echo ""
}

# Main execution flow
main() {
    parse_args "$@"
    validate_source
    validate_target
    select_skills
    confirm_selection
    create_symlinks
    print_report
}

main "$@"