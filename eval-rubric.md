# Setup Quality Evaluation Rubric

You are evaluating the output of a `/setup` command that configures an Obsidian vault with Claude Code rules based on a user interview (persona). You will be given:

1. The **persona fixture** — the user's answers about their role, org, people, work, thinking preferences, and workflow
2. The **generated files** — the rules, context notes, and person notes that /setup created

Score each dimension 1-5. Provide brief evidence (quote or cite the specific file/section). Be strict — a 3 is acceptable, a 5 means genuinely impressive personalization that would surprise the user.

## Dimensions

### 1. Personalization Depth (user-profile.md)
Does the profile reflect THIS specific person, or could it describe anyone with their job title?

| Score | Criteria |
|-------|----------|
| 1 | Generic job description. "Product Manager with cross-functional experience." |
| 2 | Mentions their domain but no specific expertise or style details |
| 3 | Captures domain expertise and communication preferences from persona |
| 4 | Integrates specific details (tools, frameworks, domain quirks) that would change Claude's behavior |
| 5 | A colleague would recognize this person from the profile alone |

### 2. Thinking Partner Calibration (thinking-partner.md)
Are trigger scenarios, pushback rules, and stress tests specific to their actual challenges?

| Score | Criteria |
|-------|----------|
| 1 | Generic "challenge assumptions" advice. Could apply to any manager. |
| 2 | Mentions their domain but trigger scenarios are vague |
| 3 | Trigger scenarios map to real challenges from the persona. Pushback rules reference specific dynamics. |
| 4 | Decision calibration table uses examples from their actual work. Stress test mode addresses their specific risks. |
| 5 | Captures the nuance of their org dynamics — who needs what framing, where the real tensions are, what keeps them up at night |

### 3. Decision Calibration Accuracy (thinking-partner.md)
Does the commitment/velocity table match their domain reality?

| Score | Criteria |
|-------|----------|
| 1 | Copy-pasted from the template with no changes |
| 2 | Changed the examples but levels don't match the domain (e.g., treating a SaaS config change as "high commitment" for a startup) |
| 3 | Levels and examples are domain-appropriate |
| 4 | Examples reference their actual projects and decisions at the right commitment level |
| 5 | Captures domain-specific irreversibility correctly (e.g., hardware tooling lock vs. feature flag, union response vs. policy draft) |

### 4. Work State Completeness (work-state.md)
Are all projects from the persona tracked with meaningful status?

| Score | Criteria |
|-------|----------|
| 1 | Missing projects or empty "Left Off" fields |
| 2 | Projects listed but "Left Off" is generic ("in progress") |
| 3 | All projects present with specific status from the persona |
| 4 | Status captures current phase, blockers, and next steps from persona details |
| 5 | Organizes projects under the right context headers, captures dependencies between projects |

### 5. Collaborator Modeling (person notes + collaborators.md)

> **Expected output:** Individual person notes at `Contexts/[Context]/People/[Name].md` PLUS a collaborators.md overview at `.claude/rules/[context-name]/collaborators.md` (in the context-specific rules section). The overview groups people by team/role with relationship dynamics and framing guidance. Check both locations before scoring.

Do person notes capture decision styles, relationships, and communication patterns?

| Score | Criteria |
|-------|----------|
| 1 | Just name and title. No relationship context. |
| 2 | Title and team, but missing the dynamics that matter (how they make decisions, what framing works) |
| 3 | Key relationship details present — reports-to, meeting cadence, general disposition |
| 4 | Captures what matters for the user's work — decision styles, what framing lands, tensions and alliances |
| 5 | A new PM taking over this vault could navigate every stakeholder relationship from these notes. collaborators.md serves as a navigable overview with groupings, decision styles, and framing guidance that complements the individual person notes. |

### 6. Voice Match (writing-style.md)
Does the writing style reflect the persona's stated communication preferences?

| Score | Criteria |
|-------|----------|
| 1 | Generic "be clear and concise" |
| 2 | Mentions their preference but doesn't operationalize it (says "direct" but no rules about what that means) |
| 3 | Communication preferences translated into actionable rules (format preferences, register, tone) |
| 4 | Voice calibration table populated with their actual communication contexts and registers |
| 5 | Anti-tells and preferred alternatives customized to avoid patterns that would undermine their credibility |

### 7. Information Fidelity
Was anything fabricated? Was anything significant dropped?

| Score | Criteria |
|-------|----------|
| 1 | Fabricated details not in the persona (invented projects, people, or org details) |
| 2 | No fabrication but significant persona details missing from output |
| 3 | All major details preserved, minor items may be absent |
| 4 | Comprehensive coverage — hard to find anything from the persona that wasn't captured somewhere |
| 5 | Perfect fidelity — every detail placed in the right file with no additions or omissions |

**Fabrication is an automatic cap at 1 for this dimension regardless of other qualities.**

### 8. Structural Correctness
Do files follow expected patterns — frontmatter, note types, folder structure?

| Score | Criteria |
|-------|----------|
| 1 | Missing frontmatter, wrong note types, broken structure |
| 2 | Frontmatter present but fields wrong or missing required fields (type, context) |
| 3 | Structure correct — right folders, right frontmatter, right note types |
| 4 | Clean structure with correct wikilinks in context fields, proper hierarchy |
| 5 | Production-ready — matches the vault conventions documented in the starter kit scaffolding |

## Output Format

Respond with ONLY a JSON object (no markdown fences, no commentary before or after):

{
  "persona": "<persona-name>",
  "scores": {
    "personalization_depth": { "score": N, "evidence": "..." },
    "thinking_partner_calibration": { "score": N, "evidence": "..." },
    "decision_calibration": { "score": N, "evidence": "..." },
    "work_state_completeness": { "score": N, "evidence": "..." },
    "collaborator_modeling": { "score": N, "evidence": "..." },
    "voice_match": { "score": N, "evidence": "..." },
    "information_fidelity": { "score": N, "evidence": "..." },
    "structural_correctness": { "score": N, "evidence": "..." }
  },
  "overall": N.N,
  "strengths": ["...", "..."],
  "weaknesses": ["...", "..."],
  "fabrications": ["..." or empty array if none]
}

"overall" is the mean of all 8 scores, rounded to one decimal. If information_fidelity is capped at 1 due to fabrication, note the fabricated items in "fabrications".
