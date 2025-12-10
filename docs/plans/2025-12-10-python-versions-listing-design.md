# Python Versions Listing Feature Design

**Date:** 2025-12-10
**Feature:** List available Python versions for virtual environment creation

## Overview

Add a `virtualenv-python-versions` command that displays all Python executables available in the user's PATH that can create virtual environments. This helps users discover which Python versions they can use with the `--python` flag when creating virtual environments.

## Command Specification

**Command name:** `virtualenv-python-versions`

**Purpose:** Display all Python executables available in the user's PATH that can create virtual environments.

**Usage:**
```bash
virtualenv-python-versions
```

**Example output:**
```
Available Python versions:
  python3.13
  python3.12
  python3.10
  python3

Use with: virtualenv-create <name> --python <version>
```

## Behavior

1. Searches through all directories in the user's PATH environment variable
2. Finds all executables matching the pattern `python*` (python, python3, python3.10, python3.13, etc.)
3. Validates each Python by checking if it has the `venv` module available
4. Displays a clean list of executable names, sorted by version (newest first)
5. Shows a helpful message if no Python versions are found

## Implementation Details

### Discovery Algorithm

1. Split PATH into individual directories
2. For each directory, list all files matching `python*` pattern
3. For each file, verify it's executable
4. Test if it has venv module using: `$python -m venv --help >/dev/null 2>&1`
5. If successful, add the executable name to results list
6. Remove duplicates (keep first occurrence)
7. Sort results by version number intelligently (3.13 before 3.10 before 3.9)

### Integration Points

- Add the function after `virtualenv-info` (around line 351 in venvframework.sh)
- Update `virtualenv-help` to include the new command
- Update README.md to document the new command in:
  - Commands Reference table
  - Usage examples section
- No changes needed to existing functions

### Code Structure

```bash
virtualenv-python-versions() {
    # Validate PATH exists
    # Search PATH directories for python* executables
    # Validate each has venv module
    # Sort and deduplicate
    # Display formatted list
}
```

The function will use similar patterns to existing functions (error handling, output formatting) to maintain consistency with the framework.

## Error Handling

- **PATH empty or unset:** Display "Error: PATH environment variable is not set"
- **No Python versions found:** Display "No Python installations found in PATH"
- **Python check fails:** Skip silently and continue (handles permission denied, broken installations)
- **Directory in PATH doesn't exist:** Skip silently and continue

## User Messaging

- **Success:** Clear list with usage hint
- **Empty result:** Helpful message suggesting to install Python or check PATH
- **Consistent formatting:** Match existing command style (indentation, spacing)

## Testing Scenarios

1. Normal case: Multiple Python versions installed
2. Single Python version
3. No Python installations
4. Python without venv module (like some minimal Python builds)
5. Broken Python executable in PATH
6. PATH contains non-existent directories

## Documentation Updates

### virtualenv-help updates
Add to commands list:
```
virtualenv-python-versions           List available Python versions
```

### README.md updates

Add to Commands Reference table:
```markdown
| `virtualenv-python-versions` | List available Python versions for virtual environments |
```

Add to usage examples:
```markdown
### List available Python versions
```bash
virtualenv-python-versions
```

This shows all Python installations in your PATH that can create virtual environments.
```

## Design Decisions

### Why search only PATH?
- Respects user's environment setup
- Only shows Python versions the user can actually run
- Portable across different systems (Linux, macOS, WSL, etc.)
- Consistent with how shell commands work

### Why validate venv capability?
- Ensures every listed version will work with `virtualenv-create`
- Prevents user frustration from trying non-functional Python installations
- Filters out minimal Python builds that lack venv module

### Why show executable names only?
- Simple and clean output
- Names can be used directly with `--python` flag
- Avoids overhead of querying each Python version
- User can run `python3.10 --version` themselves if they want details

### Why sort newest first?
- Users typically want the latest Python version
- Matches common convention in package managers
- Makes it easy to find the newest available version
