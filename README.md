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
```

## Structure

```
personas/           Fixture files — fictional user profiles for /setup
baselines/          Known-good output snapshots (saved with --save)
results/            Test run output (gitignored)
run-test.sh         Main runner: clones starter kit, runs /setup, validates
validate.sh         Output validation checks
```

## Adding a Persona

1. Create `personas/your-persona.md` following the existing format (Phase 1-6 answers)
2. Add persona-specific validation checks in `validate.sh` under a new `case` block
3. Run `bash run-test.sh personas/your-persona.md --local <path>` to test
4. Run with `--save` to create a baseline

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Git
- Bash 4+
