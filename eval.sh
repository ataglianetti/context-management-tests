#!/usr/bin/env bash
# LLM-based quality evaluation of /setup output.
#
# Usage:
#   bash eval.sh <results-dir> <persona-file>
#   bash eval.sh results/startup-ceo/vault personas/startup-ceo.md
#   bash eval.sh --all                    # eval all completed runs in results/
#   bash eval.sh --all --model sonnet     # use sonnet instead of haiku
#
# Requires: claude CLI, jq
# Produces: results/<persona>/eval-report.json + terminal summary

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
PERSONAS_DIR="$SCRIPT_DIR/personas"
RUBRIC_FILE="$SCRIPT_DIR/eval-rubric.md"

MODEL="haiku"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

usage() {
  echo "Usage: $0 <results-vault-dir> <persona-file> [--model <model>]"
  echo "       $0 --all [--model <model>]"
  echo ""
  echo "  --all              Evaluate all completed runs in results/"
  echo "  --model <model>    Claude model to use for eval (default: haiku)"
  echo "                     Options: haiku, sonnet, opus"
  exit 1
}

# Collect generated files into a single text block for the eval prompt
collect_generated_files() {
  local vault_dir="$1"
  local output=""

  # Core rules (the main generated files)
  for rule_file in user-profile.md thinking-partner.md work-state.md writing-style.md memory.md; do
    local fpath="$vault_dir/.claude/rules/core/$rule_file"
    if [ -f "$fpath" ]; then
      output+="
=== .claude/rules/core/$rule_file ===
$(cat "$fpath")
"
    fi
  done

  # Context-specific rules (find all non-core, non-vault rule dirs)
  find "$vault_dir/.claude/rules" -mindepth 2 -name "*.md" -not -path "*/core/*" -not -path "*/vault/*" 2>/dev/null | sort | while read -r f; do
    local rel_path="${f#$vault_dir/}"
    echo ""
    echo "=== $rel_path ==="
    cat "$f"
  done | { output+="$(cat)"; echo "$output"; }

  # Context notes and person notes
  if [ -d "$vault_dir/Contexts" ]; then
    find "$vault_dir/Contexts" -name "*.md" 2>/dev/null | sort | while read -r f; do
      local rel_path="${f#$vault_dir/}"
      echo ""
      echo "=== $rel_path ==="
      cat "$f"
    done
  fi
}

eval_persona() {
  local vault_dir="$1"
  local persona_file="$2"
  local persona_name
  persona_name="$(basename "$persona_file" .md)"
  local report_file="$RESULTS_DIR/$persona_name/eval-report.json"
  local report_md="$RESULTS_DIR/$persona_name/eval-report.md"

  echo -e "${YELLOW}━━━ Evaluating: $persona_name ━━━${NC}"

  # Check that the run completed
  if [ ! -d "$vault_dir" ]; then
    echo -e "  ${RED}No results found at $vault_dir — run tests first${NC}"
    return 1
  fi

  if [ ! -d "$vault_dir/Contexts" ]; then
    echo -e "  ${RED}No Contexts/ directory — setup may have failed${NC}"
    return 1
  fi

  # Read inputs
  local persona_content
  persona_content="$(cat "$persona_file")"

  local generated_content
  generated_content="$(collect_generated_files "$vault_dir")"

  local rubric_content
  rubric_content="$(cat "$RUBRIC_FILE")"

  # Build eval prompt
  local prompt
  prompt="$(cat <<EVALPROMPT
$rubric_content

---

## Persona Fixture (the input)

$persona_content

---

## Generated Files (the output to evaluate)

$generated_content
EVALPROMPT
)"

  # Run eval via claude
  echo "  Running LLM evaluation (model: $MODEL)..."
  local start_time
  start_time=$(date +%s)

  local raw_output
  if raw_output=$(claude -p \
    --model "$MODEL" \
    --no-session-persistence \
    "$prompt" \
    2>/dev/null); then
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))
    echo -e "  ${GREEN}Eval completed in ${duration}s${NC}"
  else
    echo -e "  ${RED}Eval failed${NC}"
    return 1
  fi

  # Extract JSON from the response (handle potential markdown fences)
  local json_output
  json_output=$(echo "$raw_output" | sed -n '/^{/,/^}/p')

  # If that didn't work, try stripping markdown fences
  if [ -z "$json_output" ] || ! echo "$json_output" | jq . >/dev/null 2>&1; then
    json_output=$(echo "$raw_output" | sed 's/^```json//' | sed 's/^```//' | sed -n '/^{/,/^}/p')
  fi

  # Validate JSON
  if ! echo "$json_output" | jq . >/dev/null 2>&1; then
    echo -e "  ${RED}Failed to parse eval response as JSON${NC}"
    echo "  Raw output saved to $RESULTS_DIR/$persona_name/eval-raw.txt"
    echo "$raw_output" > "$RESULTS_DIR/$persona_name/eval-raw.txt"
    return 1
  fi

  # Save JSON report
  echo "$json_output" | jq . > "$report_file"

  # Generate markdown report
  generate_report "$json_output" "$persona_name" > "$report_md"

  # Print summary
  print_summary "$json_output" "$persona_name"

  echo ""
}

print_summary() {
  local json="$1"
  local persona="$2"

  local overall
  overall=$(echo "$json" | jq -r '.overall')

  # Color the overall score
  local score_color="$RED"
  if (( $(echo "$overall >= 4.0" | bc -l) )); then
    score_color="$GREEN"
  elif (( $(echo "$overall >= 3.0" | bc -l) )); then
    score_color="$YELLOW"
  fi

  echo ""
  echo -e "  ${BOLD}Overall: ${score_color}${overall}/5.0${NC}"
  echo ""

  # Print dimension scores as a compact table
  echo "$json" | jq -r '.scores | to_entries[] | "\(.key)|\(.value.score)"' | while IFS='|' read -r dim score; do
    local label
    label=$(echo "$dim" | tr '_' ' ')
    local color="$RED"
    if [ "$score" -ge 4 ]; then
      color="$GREEN"
    elif [ "$score" -ge 3 ]; then
      color="$YELLOW"
    fi
    printf "  ${color}%s${NC}  %s\n" "$score" "$label"
  done

  # Fabrications warning
  local fab_count
  fab_count=$(echo "$json" | jq '.fabrications | length')
  if [ "$fab_count" -gt 0 ]; then
    echo ""
    echo -e "  ${RED}FABRICATIONS DETECTED:${NC}"
    echo "$json" | jq -r '.fabrications[]' | while read -r fab; do
      echo -e "    ${RED}• $fab${NC}"
    done
  fi

  # Strengths / weaknesses
  echo ""
  echo -e "  ${CYAN}Strengths:${NC}"
  echo "$json" | jq -r '.strengths[]' | while read -r s; do
    echo "    + $s"
  done
  echo -e "  ${CYAN}Weaknesses:${NC}"
  echo "$json" | jq -r '.weaknesses[]' | while read -r w; do
    echo "    - $w"
  done
}

generate_report() {
  local json="$1"
  local persona="$2"

  local overall
  overall=$(echo "$json" | jq -r '.overall')
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M")

  cat <<REPORT
# Eval Report: $persona

**Date:** $timestamp
**Model:** $MODEL
**Overall Score:** $overall / 5.0

## Dimension Scores

| Dimension | Score | Evidence |
|-----------|-------|----------|
REPORT

  echo "$json" | jq -r '.scores | to_entries[] | "| \(.key | gsub("_";" ")) | \(.value.score) | \(.value.evidence) |"'

  cat <<REPORT

## Strengths
REPORT
  echo "$json" | jq -r '.strengths[]' | while read -r s; do echo "- $s"; done

  cat <<REPORT

## Weaknesses
REPORT
  echo "$json" | jq -r '.weaknesses[]' | while read -r w; do echo "- $w"; done

  local fab_count
  fab_count=$(echo "$json" | jq '.fabrications | length')
  if [ "$fab_count" -gt 0 ]; then
    cat <<REPORT

## Fabrications
REPORT
    echo "$json" | jq -r '.fabrications[]' | while read -r f; do echo "- $f"; done
  fi
}

# ─── ARGUMENT PARSING ───

evals=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      # Find all completed persona runs
      for dir in "$RESULTS_DIR"/*/vault; do
        if [ -d "$dir/Contexts" ]; then
          local_persona_name="$(basename "$(dirname "$dir")")"
          local_persona_file="$PERSONAS_DIR/${local_persona_name}.md"
          if [ -f "$local_persona_file" ]; then
            evals+=("$dir|$local_persona_file")
          fi
        fi
      done
      shift
      ;;
    --model)
      MODEL="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      # Expect pairs: vault-dir persona-file
      if [ -z "${2:-}" ]; then
        usage
      fi
      evals+=("$1|$2")
      shift 2
      ;;
  esac
done

if [ ${#evals[@]} -eq 0 ]; then
  usage
fi

# ─── RUN EVALS ───

total_score=0
eval_count=0

for entry in "${evals[@]}"; do
  IFS='|' read -r vault_dir persona_file <<< "$entry"
  if eval_persona "$vault_dir" "$persona_file"; then
    persona_name="$(basename "$persona_file" .md)"
    score=$(jq -r '.overall' "$RESULTS_DIR/$persona_name/eval-report.json" 2>/dev/null || echo "0")
    total_score=$(echo "$total_score + $score" | bc)
    ((eval_count++))
  fi
done

# ─── AGGREGATE SUMMARY ───

if [ $eval_count -gt 1 ]; then
  avg=$(echo "scale=1; $total_score / $eval_count" | bc)
  echo -e "${YELLOW}━━━ Aggregate ━━━${NC}"
  echo -e "  Personas evaluated: $eval_count"
  echo -e "  Average score: ${BOLD}$avg / 5.0${NC}"
fi
