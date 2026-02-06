# AGENTS.md

Centralised AI agent instructions. Add coding guidelines, style guides, and project context here.

Ruler concatenates all .md files in this directory (and subdirectories), starting with AGENTS.md (if present), then remaining files in sorted order.

## Running Tests

Always use `super test` to run tests.

### Unit Tests
- Run all unit tests: `super utest`
- Run a specific file: `super test test_file.py`

### Integration Tests
- Run all integration tests: `super itest`
- Run a specific file: `super test name_of_the_test_file.py`
- Using full path: `super test tests/integration/test_name.py`

### Running Specific Test Methods
- Run by test name: `super test test_name`

### Troubleshooting

If you see `Ran 0 tests in 0.000s`, the command was run incorrectly. Double-check:
1. The test file/method name is correct
2. You're using the proper `super test` command format
3. The test file exists at the specified path
