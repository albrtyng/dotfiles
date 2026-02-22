# AGENTS.md

Centralised AI agent instructions. Add coding guidelines, style guides, and project context here.

Ruler concatenates all .md files in this directory (and subdirectories), starting with AGENTS.md (if present), then remaining files in sorted order.

## Git Remote CLI

- **Always use `gh`** (GitHub CLI) for all pull request and code review operations.
- Examples: `gh pr view`, `gh pr checkout`, `gh pr comment`, `gh api ...`

### Troubleshooting

If tests produce unexpected results, double-check:
1. The test file/method name is correct
2. You're using the proper command format
3. The test file exists at the specified path
