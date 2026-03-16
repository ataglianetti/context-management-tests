#!/usr/bin/env bash
# Run /setup against a persona fixture and validate the output.
#
# Usage:
#   bash run-test.sh personas/engineering-manager.md
#   bash run-test.sh --all                                          # all personas, clone from GitHub
#   bash run-test.sh --all --local ~/Desktop/context-management-starter-kit  # use local copy
#   bash run-test.sh --all --save                                   # run all and save baselines

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PERSONAS_DIR="$SCRIPT_DIR/personas"
RESULTS_DIR="$SCRIPT_DIR/results"
BASELINES_DIR="$SCRIPT_DIR/baselines"

REMOTE_REPO="https://github.com/ataglianetti/context-management-starter-kit.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

save_baseline=false
local_path=""

usage() {
  echo "Usage: $0 <persona-file|--all> [--save] [--local <path>]"
  echo ""
  echo "  <persona-file>   Path to a persona markdown file"
  echo "  --all            Run all personas in personas/"
  echo "  --save           Save output as baseline for future comparison"
  echo "  --local <path>   Use local starter kit repo instead of cloning from GitHub"
  exit 1
}

# Parse args
personas=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      for f in "$PERSONAS_DIR"/*.md; do
        personas+=("$f")
      done
      shift
      ;;
    --save)
      save_baseline=true
      shift
      ;;
    --local)
      local_path="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      personas+=("$1")
      shift
      ;;
  esac
done

if [ ${#personas[@]} -eq 0 ]; then
  usage
fi

# Resolve starter kit source once
get_starter_kit() {
  local dest="$1"

  if [ -n "$local_path" ]; then
    echo "  Cloning from local path: $local_path"
    git clone --quiet "$local_path" "$dest" 2>/dev/null
  else
    echo "  Cloning from GitHub: $REMOTE_REPO"
    git clone --quiet --depth 1 "$REMOTE_REPO" "$dest" 2>/dev/null
  fi

  # Remove git history (it's a test, not a real repo)
  rm -rf "$dest/.git"
}

run_persona() {
  local persona_file="$1"
  local persona_name
  persona_name="$(basename "$persona_file" .md)"
  local work_dir="$RESULTS_DIR/$persona_name"

  echo -e "${YELLOW}━━━ Testing persona: $persona_name ━━━${NC}"

  # Clean up previous run
  rm -rf "$work_dir"
  mkdir -p "$work_dir"

  # Clone the starter kit into a clean working directory
  get_starter_kit "$work_dir/vault"

  # Remove any previous setup artifacts
  rm -rf "$work_dir/vault/Contexts"
  rm -f "$work_dir/vault/.claude/setup-state.json" 2>/dev/null || true

  # Read the persona file
  local persona_content
  persona_content="$(cat "$persona_file")"

  # Build the prompt
  local prompt
  prompt="$(cat <<PROMPT
Run /setup to completion using the following persona. Do NOT use AskUserQuestion — all answers are provided below. Work through every phase (0-6) and generate all files as if the user answered each question with the information below.

Important:
- Skip the vault rename step (Phase 0 step 6) — the folder is already named correctly for testing.
- Skip any interactive confirmations — just proceed with all defaults.
- Generate ALL files: context folders, person notes, portfolio items, rules, and work-state.
- Use the vault name specified in the persona for any references.

--- PERSONA ANSWERS ---

$persona_content

--- END PERSONA ---

Generate every file now. Work through all 6 phases silently and create the complete output.
PROMPT
)"

  # Run claude in non-interactive mode
  echo "  Running /setup (this takes 2-4 minutes)..."
  local start_time
  start_time=$(date +%s)

  if claude -p \
    --dangerously-skip-permissions \
    --model sonnet \
    --no-session-persistence \
    "$prompt" \
    > "$work_dir/claude-output.txt" 2>"$work_dir/claude-errors.txt" \
    ; then
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))
    echo -e "  ${GREEN}Setup completed in ${duration}s${NC}"
  else
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))
    echo -e "  ${RED}Setup failed after ${duration}s${NC}"
    echo "  Error output:"
    head -20 "$work_dir/claude-errors.txt" | sed 's/^/    /'
    return 1
  fi

  # Run validation
  echo "  Validating output..."
  bash "$SCRIPT_DIR/validate.sh" "$work_dir/vault" "$persona_file" | sed 's/^/  /'

  # Save baseline if requested
  if [ "$save_baseline" = true ]; then
    local baseline_dir="$BASELINES_DIR/$persona_name"
    rm -rf "$baseline_dir"
    mkdir -p "$baseline_dir"
    if [ -d "$work_dir/vault/Contexts" ]; then
      cp -R "$work_dir/vault/Contexts" "$baseline_dir/"
    fi
    if [ -d "$work_dir/vault/.claude/rules" ]; then
      cp -R "$work_dir/vault/.claude/rules" "$baseline_dir/rules"
    fi
    echo -e "  ${GREEN}Baseline saved to $baseline_dir${NC}"
  fi

  # Compare to baseline if one exists
  local baseline_dir="$BASELINES_DIR/$persona_name"
  if [ -d "$baseline_dir" ] && [ "$save_baseline" = false ]; then
    echo "  Comparing to baseline..."
    local diff_output
    diff_output="$(diff -rq "$baseline_dir" "$work_dir/vault/Contexts" 2>/dev/null || true)"
    if [ -z "$diff_output" ]; then
      echo -e "  ${GREEN}Output matches baseline${NC}"
    else
      echo -e "  ${YELLOW}Differences from baseline:${NC}"
      echo "$diff_output" | head -20 | sed 's/^/    /'
    fi
  fi

  echo ""
}

# Run each persona
mkdir -p "$RESULTS_DIR"
pass=0
fail=0

for persona in "${personas[@]}"; do
  if run_persona "$persona"; then
    ((pass++))
  else
    ((fail++))
  fi
done

# Summary
echo -e "${YELLOW}━━━ Results ━━━${NC}"
echo -e "  ${GREEN}Passed: $pass${NC}"
if [ $fail -gt 0 ]; then
  echo -e "  ${RED}Failed: $fail${NC}"
  exit 1
else
  echo -e "  Failed: 0"
fi
