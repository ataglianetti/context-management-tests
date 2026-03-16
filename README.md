# context-management-tests

Test infrastructure for [context-management-starter-kit](https://github.com/ataglianetti/context-management-starter-kit). Runs `/setup` against persona fixtures and validates the output.

Separated from the starter kit so users cloning the template don't get test personas and tooling they don't need.

## Usage

```bash
# Run all personas against the remote repo
bash run-test.sh --all

# Run all personas against a local copy (faster, for development)
bash run-test.sh --all --local ~/Desktop/context-management-starter-kit

# Single persona
bash run-test.sh personas/startup-ceo.md

# Run and save baselines for future comparison
bash run-test.sh --all --save --local ~/Desktop/context-management-starter-kit

# Run with LLM quality evaluation (adds ~30s per persona)
bash run-test.sh --all --eval --local ~/Desktop/context-management-starter-kit

# Use sonnet for higher-quality eval (default is haiku for speed)
bash run-test.sh --all --eval --eval-model sonnet --local ~/Desktop/context-management-starter-kit
```

### Eval Only (on existing results)

If you've already run tests and want to evaluate without re-running `/setup`:

```bash
# Evaluate all completed runs
bash eval.sh --all

# Evaluate a single persona
bash eval.sh results/startup-ceo/vault personas/startup-ceo.md

# Use a different model
bash eval.sh --all --model sonnet
```

## Two-Layer Validation

### Layer 1: Structural (validate.sh)
Fast, deterministic checks. Did `/setup` produce the right files?

- Expected directories and files exist
- Frontmatter has required fields (`type:`, `context:`)
- Key persona content appears in generated files (keyword matching)
- Scaffolding files weren't corrupted

### Layer 2: Quality (eval.sh)
LLM-as-judge scoring against an 8-dimension rubric. Is the output actually good?

| Dimension | What it measures |
|-----------|------------------|
| Personalization Depth | Does user-profile.md reflect THIS person, not a generic template? |
| Thinking Partner Calibration | Are trigger scenarios specific to their actual challenges? |
| Decision Calibration | Do commitment levels match their domain reality? |
| Work State Completeness | Are all projects tracked with meaningful status? |
| Collaborator Modeling | Do person notes capture decision styles and relationships? |
| Voice Match | Does writing-style.md operationalize their communication preferences? |
| Information Fidelity | Nothing fabricated, nothing significant dropped |
| Structural Correctness | Frontmatter, note types, folder structure follow conventions |

Each dimension scored 1-5. Fabrication in any generated file automatically caps Information Fidelity at 1.

**Output:** `results/<persona>/eval-report.json` (machine-readable) + `results/<persona>/eval-report.md` (human-readable).

## Structure

```
personas/           Fixture files — fictional user profiles for /setup
baselines/          Known-good output snapshots (saved with --save)
results/            Test run output (gitignored)
run-test.sh         Main runner: clones starter kit, runs /setup, validates
validate.sh         Structural validation checks
eval.sh             LLM quality evaluation
eval-rubric.md      Scoring rubric (fed to the evaluator model)
```

## Adding a Persona

1. Create `personas/your-persona.md` following the existing format (Phase 1-6 answers)
2. Add persona-specific validation checks in `validate.sh` under a new `case` block
3. Run `bash run-test.sh personas/your-persona.md --local <path>` to test
4. Run with `--eval` to check quality
5. Run with `--save` to create a baseline

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Git
- Bash 4+
- `jq` (for eval report parsing)
