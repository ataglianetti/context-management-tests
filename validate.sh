#!/usr/bin/env bash
# Validate /setup output against persona expectations.
#
# Usage: bash tests/validate.sh <vault-dir> <persona-file>
#
# Checks:
# 1. Expected files exist
# 2. Frontmatter has required fields (type:, context:)
# 3. Key content from persona appears in generated files
# 4. No scaffolding files were corrupted

set -euo pipefail

VAULT_DIR="$1"
PERSONA_FILE="$2"
PERSONA_NAME="$(basename "$PERSONA_FILE" .md)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass=0
fail=0
warn=0

check() {
  local description="$1"
  local result="$2"  # 0 = pass, 1 = fail, 2 = warn

  if [ "$result" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC} $description"
    pass=$((pass + 1))
  elif [ "$result" -eq 2 ]; then
    echo -e "${YELLOW}WARN${NC} $description"
    warn=$((warn + 1))
  else
    echo -e "${RED}FAIL${NC} $description"
    fail=$((fail + 1))
  fi
}

file_exists() {
  if [ -e "$VAULT_DIR/$1" ]; then
    check "File exists: $1" 0
  else
    check "File exists: $1" 1
  fi
}

dir_exists() {
  if [ -d "$VAULT_DIR/$1" ]; then
    check "Directory exists: $1" 0
  else
    check "Directory exists: $1" 1
  fi
}

has_frontmatter_field() {
  local file="$VAULT_DIR/$1"
  local field="$2"

  if [ ! -f "$file" ]; then
    check "Frontmatter '$field' in $1" 1
    return
  fi

  # Extract YAML frontmatter (between --- delimiters) and check for field
  if awk '/^---$/{if(n++)exit}n' "$file" | grep -q "^${field}:"; then
    check "Frontmatter '$field' in $1" 0
  else
    check "Frontmatter '$field' in $1" 1
  fi
}

file_contains() {
  local file="$VAULT_DIR/$1"
  local pattern="$2"
  local description="${3:-Pattern '$pattern' in $1}"

  if [ ! -f "$file" ]; then
    check "$description" 1
    return
  fi

  if grep -qi "$pattern" "$file"; then
    check "$description" 0
  else
    check "$description" 1
  fi
}

scaffolding_intact() {
  local file="$1"
  if [ ! -f "$VAULT_DIR/$file" ]; then
    check "Scaffolding intact: $file" 2
    return
  fi
  check "Scaffolding intact: $file" 0
}

# ─── UNIVERSAL CHECKS (all personas) ───

echo "── Structure ──"
dir_exists "Contexts"
dir_exists "Calendar"
dir_exists "Resources/Templates"

echo ""
echo "── Scaffolding Files ──"
scaffolding_intact ".claude/rules/core/hard-walls.md"
scaffolding_intact ".claude/rules/core/session-protocol.md"
scaffolding_intact ".claude/rules/core/document-traversal.md"
scaffolding_intact ".claude/rules/vault/vault-structure.md"
scaffolding_intact ".claude/rules/vault/file-management.md"
scaffolding_intact ".claude/rules/vault/summarization.md"
scaffolding_intact ".claude/hooks/validate-frontmatter.sh"
scaffolding_intact ".claude/hooks/validate-dates.sh"
scaffolding_intact ".claude/hooks/validate-wikilinks.sh"

echo ""
echo "── Generated Core Rules ──"
file_exists ".claude/rules/core/user-profile.md"
file_exists ".claude/rules/core/thinking-partner.md"
file_exists ".claude/rules/core/work-state.md"
file_exists ".claude/rules/core/writing-style.md"

# Check user-profile has key sections
if [ -f "$VAULT_DIR/.claude/rules/core/user-profile.md" ]; then
  file_contains ".claude/rules/core/user-profile.md" "Proficiency" "user-profile.md has Proficiency section"
  file_contains ".claude/rules/core/user-profile.md" "Pacing" "user-profile.md has Pacing section"
fi

# Check thinking-partner has key sections
if [ -f "$VAULT_DIR/.claude/rules/core/thinking-partner.md" ]; then
  file_contains ".claude/rules/core/thinking-partner.md" "Trigger Scenarios" "thinking-partner.md has Trigger Scenarios"
  file_contains ".claude/rules/core/thinking-partner.md" "Decision Calibration" "thinking-partner.md has Decision Calibration"
  file_contains ".claude/rules/core/thinking-partner.md" "Stress Test" "thinking-partner.md has Stress Test Mode"
  file_contains ".claude/rules/core/thinking-partner.md" "Push Back" "thinking-partner.md has When to Push Back"
fi

# Check work-state has project table
if [ -f "$VAULT_DIR/.claude/rules/core/work-state.md" ]; then
  file_contains ".claude/rules/core/work-state.md" "Project.*State.*Last Touched" "work-state.md has project table headers"
fi

# ─── PERSONA-SPECIFIC CHECKS ───

echo ""
echo "── Persona-Specific: $PERSONA_NAME ──"

case "$PERSONA_NAME" in
  engineering-manager)
    # Context
    dir_exists "Contexts/PayFlow"
    file_exists "Contexts/PayFlow/PayFlow.md"
    has_frontmatter_field "Contexts/PayFlow/PayFlow.md" "type"

    # People
    dir_exists "Contexts/PayFlow/People"
    file_exists "Contexts/PayFlow/People/Sarah Chen.md"
    file_exists "Contexts/PayFlow/People/Priya Patel.md"
    file_exists "Contexts/PayFlow/People/James Liu.md"
    file_exists "Contexts/PayFlow/People/Rachel Torres.md"
    file_exists "Contexts/PayFlow/People/Dev Sharma.md"
    file_exists "Contexts/PayFlow/People/Alex Kim.md"

    # People frontmatter
    has_frontmatter_field "Contexts/PayFlow/People/Sarah Chen.md" "type"
    has_frontmatter_field "Contexts/PayFlow/People/Sarah Chen.md" "context"

    # Portfolio
    dir_exists "Contexts/PayFlow/Portfolio"

    # Context rules
    file_exists ".claude/rules/payflow/context.md"
    file_exists ".claude/rules/payflow/collaborators.md"

    # Content checks
    file_contains ".claude/rules/core/user-profile.md" "distributed systems" "user-profile mentions distributed systems"
    file_contains ".claude/rules/core/thinking-partner.md" "monolith" "thinking-partner mentions monolith migration"
    file_contains ".claude/rules/core/thinking-partner.md" "Priya" "thinking-partner mentions key person Priya"
    file_contains ".claude/rules/core/work-state.md" "API Gateway" "work-state tracks API Gateway project"
    file_contains ".claude/rules/core/work-state.md" "Monolith" "work-state tracks Monolith Migration"

    # Marcus (CTO) should appear - cares about uptime
    file_exists "Contexts/PayFlow/People/Marcus Webb.md"
    ;;

  hr-director)
    # Context
    dir_exists "Contexts/Greenline Health"
    file_exists "Contexts/Greenline Health/Greenline Health.md"
    has_frontmatter_field "Contexts/Greenline Health/Greenline Health.md" "type"

    # People
    dir_exists "Contexts/Greenline Health/People"
    file_exists "Contexts/Greenline Health/People/Diana Reeves.md"
    file_exists "Contexts/Greenline Health/People/Tom Langford.md"
    file_exists "Contexts/Greenline Health/People/Maria Santos.md"
    file_exists "Contexts/Greenline Health/People/Rob Fielding.md"
    file_exists "Contexts/Greenline Health/People/Jennifer Walsh.md"

    # People frontmatter
    has_frontmatter_field "Contexts/Greenline Health/People/Diana Reeves.md" "type"
    has_frontmatter_field "Contexts/Greenline Health/People/Diana Reeves.md" "context"

    # Portfolio
    dir_exists "Contexts/Greenline Health/Portfolio"

    # Context rules
    file_exists ".claude/rules/greenline-health/context.md"
    file_exists ".claude/rules/greenline-health/collaborators.md"

    # Content checks
    file_contains ".claude/rules/core/user-profile.md" "employment law" "user-profile mentions employment law"
    file_contains ".claude/rules/core/thinking-partner.md" "compliance" "thinking-partner mentions compliance"
    file_contains ".claude/rules/core/thinking-partner.md" "union" "thinking-partner mentions union dynamics"
    file_contains ".claude/rules/core/work-state.md" "Compensation" "work-state tracks Compensation Redesign"
    file_contains ".claude/rules/core/work-state.md" "Turnover" "work-state tracks Clinical Turnover"
    file_contains ".claude/rules/core/work-state.md" "Workday" "work-state tracks Workday Phase 2"

    # Domain-specific thinking partner checks
    file_contains ".claude/rules/core/thinking-partner.md" "legal" "thinking-partner addresses legal risk"
    file_contains ".claude/rules/core/thinking-partner.md" "Diana" "thinking-partner mentions Diana's pacing"
    ;;

  startup-ceo)
    # Context
    dir_exists "Contexts/Canopy"
    file_exists "Contexts/Canopy/Canopy.md"
    has_frontmatter_field "Contexts/Canopy/Canopy.md" "type"

    # People
    dir_exists "Contexts/Canopy/People"
    file_exists "Contexts/Canopy/People/Raj Patel.md"
    file_exists "Contexts/Canopy/People/Megan Torres.md"
    file_exists "Contexts/Canopy/People/Sophie Martinez.md"
    file_exists "Contexts/Canopy/People/Nate Brooks.md"
    file_exists "Contexts/Canopy/People/Carlos Mendez.md"
    file_exists "Contexts/Canopy/People/Anya Petrov.md"

    # People frontmatter
    has_frontmatter_field "Contexts/Canopy/People/Raj Patel.md" "type"
    has_frontmatter_field "Contexts/Canopy/People/Raj Patel.md" "context"

    # Portfolio
    dir_exists "Contexts/Canopy/Portfolio"

    # Context rules
    file_exists ".claude/rules/canopy/context.md"
    file_exists ".claude/rules/canopy/collaborators.md"
    file_exists ".claude/rules/canopy/portfolio.md"

    # Content checks
    file_contains ".claude/rules/core/user-profile.md" "fundraising" "user-profile mentions fundraising"
    file_contains ".claude/rules/core/thinking-partner.md" "runway" "thinking-partner mentions runway pressure"
    file_contains ".claude/rules/core/thinking-partner.md" "Raj" "thinking-partner mentions co-founder Raj"
    file_contains ".claude/rules/core/thinking-partner.md" "Series B" "thinking-partner mentions Series B"
    file_contains ".claude/rules/core/work-state.md" "VP Sales" "work-state tracks VP Sales Hire"
    file_contains ".claude/rules/core/work-state.md" "ELA" "work-state tracks ELA Expansion"
    file_contains ".claude/rules/core/work-state.md" "Series B" "work-state tracks Series B Preparation"

    # Board observer (secondary context check)
    file_exists "Contexts/Canopy/People/David Kim.md"

    # Domain-specific: CEO should get startup-specific stress test
    file_contains ".claude/rules/core/thinking-partner.md" "burn" "thinking-partner addresses burn rate"
    ;;

  ux-design-lead)
    # Primary context: Vantage
    dir_exists "Contexts/Vantage"
    file_exists "Contexts/Vantage/Vantage.md"
    has_frontmatter_field "Contexts/Vantage/Vantage.md" "type"

    # People
    dir_exists "Contexts/Vantage/People"
    file_exists "Contexts/Vantage/People/Rebecca Huang.md"
    file_exists "Contexts/Vantage/People/Liam Chen.md"
    file_exists "Contexts/Vantage/People/Maya Williams.md"
    file_exists "Contexts/Vantage/People/Aisha Okafor.md"

    # People frontmatter
    has_frontmatter_field "Contexts/Vantage/People/Rebecca Huang.md" "type"
    has_frontmatter_field "Contexts/Vantage/People/Rebecca Huang.md" "context"

    # Portfolio
    dir_exists "Contexts/Vantage/Portfolio"

    # Context rules
    file_exists ".claude/rules/vantage/context.md"
    file_exists ".claude/rules/vantage/collaborators.md"

    # Content checks
    file_contains ".claude/rules/core/user-profile.md" "design" "user-profile mentions design"
    file_contains ".claude/rules/core/user-profile.md" "Figma" "user-profile mentions Figma"
    file_contains ".claude/rules/core/thinking-partner.md" "design system" "thinking-partner mentions design system"
    file_contains ".claude/rules/core/thinking-partner.md" "research" "thinking-partner mentions research debt"
    file_contains ".claude/rules/core/work-state.md" "Design System" "work-state tracks Design System v2"
    file_contains ".claude/rules/core/work-state.md" "Onboarding" "work-state tracks Onboarding Redesign"

    # Freelance secondary context
    file_contains ".claude/rules/core/work-state.md" "NovaPay" "work-state tracks NovaPay freelance project"

    # Domain: design quality vs velocity tension
    file_contains ".claude/rules/core/thinking-partner.md" "velocity" "thinking-partner addresses velocity vs quality"
    ;;

  freelance-consultant)
    # Multiple client contexts (key differentiator for this persona)
    dir_exists "Contexts/Meridian Retail"
    file_exists "Contexts/Meridian Retail/Meridian Retail.md"
    has_frontmatter_field "Contexts/Meridian Retail/Meridian Retail.md" "type"

    dir_exists "Contexts/Cascadia Health Network"
    file_exists "Contexts/Cascadia Health Network/Cascadia Health Network.md"
    has_frontmatter_field "Contexts/Cascadia Health Network/Cascadia Health Network.md" "type"

    dir_exists "Contexts/Bridges Foundation"
    file_exists "Contexts/Bridges Foundation/Bridges Foundation.md"
    has_frontmatter_field "Contexts/Bridges Foundation/Bridges Foundation.md" "type"

    # People (spot-check across clients)
    file_exists "Contexts/Meridian Retail/People/Angela Torres.md"
    file_exists "Contexts/Cascadia Health Network/People/Dr. Vikram Patel.md"
    file_exists "Contexts/Bridges Foundation/People/Keisha Williams.md"
    file_exists "Contexts/Meridian Retail/People/Tom Nakamura.md"

    # People frontmatter
    has_frontmatter_field "Contexts/Meridian Retail/People/Angela Torres.md" "type"
    has_frontmatter_field "Contexts/Meridian Retail/People/Angela Torres.md" "context"

    # Portfolio in at least one context
    dir_exists "Contexts/Meridian Retail/Portfolio"

    # Context rules (at least Meridian)
    file_exists ".claude/rules/meridian-retail/context.md"
    file_exists ".claude/rules/meridian-retail/collaborators.md"

    # Content checks
    file_contains ".claude/rules/core/user-profile.md" "operating model" "user-profile mentions operating model expertise"
    file_contains ".claude/rules/core/thinking-partner.md" "capacity" "thinking-partner mentions capacity allocation"
    file_contains ".claude/rules/core/thinking-partner.md" "scope" "thinking-partner mentions scope creep"
    file_contains ".claude/rules/core/work-state.md" "Meridian" "work-state tracks Meridian engagement"
    file_contains ".claude/rules/core/work-state.md" "Cascadia" "work-state tracks Cascadia engagement"
    file_contains ".claude/rules/core/work-state.md" "Bridges" "work-state tracks Bridges engagement"

    # Subcontractor should appear
    file_contains ".claude/rules/core/work-state.md" "Business Development" "work-state tracks business development"

    # Domain: client navigation, solo practitioner
    file_contains ".claude/rules/core/thinking-partner.md" "client" "thinking-partner addresses client dynamics"
    ;;

  data-science-lead)
    # Context: Fielder Foods
    dir_exists "Contexts/Fielder Foods"
    file_exists "Contexts/Fielder Foods/Fielder Foods.md"
    has_frontmatter_field "Contexts/Fielder Foods/Fielder Foods.md" "type"

    # People
    dir_exists "Contexts/Fielder Foods/People"
    file_exists "Contexts/Fielder Foods/People/Diane Park.md"
    file_exists "Contexts/Fielder Foods/People/James Okoye.md"
    file_exists "Contexts/Fielder Foods/People/Rachel Kim.md"
    file_exists "Contexts/Fielder Foods/People/Sam Torres.md"

    # People frontmatter
    has_frontmatter_field "Contexts/Fielder Foods/People/Diane Park.md" "type"
    has_frontmatter_field "Contexts/Fielder Foods/People/Diane Park.md" "context"

    # Portfolio
    dir_exists "Contexts/Fielder Foods/Portfolio"

    # Context rules
    file_exists ".claude/rules/fielder-foods/context.md"
    file_exists ".claude/rules/fielder-foods/collaborators.md"

    # Content checks
    file_contains ".claude/rules/core/user-profile.md" "data scien" "user-profile mentions data science"
    file_contains ".claude/rules/core/user-profile.md" "Python" "user-profile mentions Python"
    file_contains ".claude/rules/core/thinking-partner.md" "marketing mix" "thinking-partner mentions marketing mix model"
    file_contains ".claude/rules/core/thinking-partner.md" "rigor" "thinking-partner addresses methodological rigor"
    file_contains ".claude/rules/core/work-state.md" "Marketing Mix" "work-state tracks Marketing Mix Model"
    file_contains ".claude/rules/core/work-state.md" "Segmentation" "work-state tracks Customer Segmentation"
    file_contains ".claude/rules/core/work-state.md" "Experimentation" "work-state tracks Experimentation Platform"

    # Domain: data quality and stakeholder translation
    file_contains ".claude/rules/core/thinking-partner.md" "data quality" "thinking-partner addresses data quality"
    ;;

  *)
    echo -e "${YELLOW}No persona-specific checks defined for: $PERSONA_NAME${NC}"
    ;;
esac

# ─── ANTI-FABRICATION CHECKS ───

echo ""
echo "── Anti-Fabrication Checks ──"

# Check portfolio items for fabricated Status tables and milestone dates
fabrication_count=0
if [ -d "$VAULT_DIR/Contexts" ]; then
  while IFS= read -r -d '' portfolio_file; do
    rel_path="${portfolio_file#$VAULT_DIR/}"
    # Check for ## Status table (should not exist at setup time)
    if grep -q "^## Status" "$portfolio_file"; then
      check "No Status table in $rel_path (setup should not create these)" 1
      ((fabrication_count++))
    fi
    # Check for milestone-date in frontmatter
    if awk '/^---$/{if(n++)exit}n' "$portfolio_file" | grep -q "^milestone-date:.\+"; then
      check "No milestone-date in $rel_path (setup should not set dates)" 1
      ((fabrication_count++))
    fi
  done < <(find "$VAULT_DIR/Contexts" -path "*/Portfolio/*/*.md" -print0 2>/dev/null)
fi

if [ "$fabrication_count" -eq 0 ]; then
  check "No fabricated milestone dates or Status tables in portfolio items" 0
fi

# ─── SUMMARY ───

echo ""
echo "── Summary ──"
total=$((pass + fail + warn))
echo -e "  ${GREEN}Pass: $pass${NC}  ${RED}Fail: $fail${NC}  ${YELLOW}Warn: $warn${NC}  Total: $total"

if [ $fail -gt 0 ]; then
  exit 1
fi
