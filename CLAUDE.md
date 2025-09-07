# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of cross-platform bash utilities for automating development tasks, managing git repositories, and maintaining system configurations. Scripts are organized by function into directories.

## Architecture

### Script Structure
- All scripts follow unofficial bash strict mode with `set -euo pipefail`
- Scripts use `lib/bash-template.sh` as a starting template
- Color output is standardized through `lib/colors.sh` which provides terminal color constants and a `color_echo()` function
- Scripts source the colors library with: `source "${SCRIPT_DIR}"/../lib/colors.sh`

### Directory Organization
- `cfg/` - System configuration and setup utilities
- `daylog/` - Daily logging and task management tools  
- `files/` - File operations and directory management
- `git/` - Git repository automation and synchronization
- `lib/` - Shared libraries and templates
- `linux/` - Linux-specific system utilities
- `updates/` - System update automation

## Development Commands

### Code Quality
```bash
# Check scripts with shellcheck (if available)
shellcheck script.sh

# The repository includes .shellcheckrc with external-sources=true
```

### Testing Scripts
Scripts include help information accessible via:
```bash
./script.sh -h
./script.sh --help
```

### Key Utilities
- `git/syncall.sh` - Synchronizes all git repositories in ~/Repos/
- `daylog/daylog.sh` - Creates and manages daily log entries
- `files/savefiletree.sh` - Generates directory trees and consolidates file contents
- `linux/toggle_touchscreen.sh` - Interactive touchscreen toggle

## Coding Standards

### Naming Conventions
- `variable_name` - Lower case with underscores for variables
- `CONSTANT_NAME` - Upper case for constants  
- `E_ERROR_CODE` - Error codes prefixed with "E_"
- `FunctionName` - Upper case for function names

### Script Requirements
- All scripts must be executable
- Include proper shebang: `#!/bin/bash`
- Use strict mode: `set -euo pipefail`
- Source color library for consistent output formatting
- Include help documentation accessible via `-h` or `--help`