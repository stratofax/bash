# bash

Cross-platform bash scripts for Linux, Mac, and Windows (via WSL or Git Bash) computers. This repository contains a collection of utilities for automating common development tasks, managing git repositories, and maintaining system configurations.

## Repository Structure

- `cfg/` - System configuration utilities
  - `install_dotfiles.sh` - Sets up dotfiles on a new computer
  - `install_source_code_pro.sh` - Installs Adobe's Source Code Pro font

- `daylog/` - Daily logging tools
  - `daylog.sh` - Creates and manages daily log entries
  - `daylog_cfg.sh` - Configures daylog settings
  - Additional scripts for organizing logs by date

- `files/` - File management utilities
  - `savefiletree.sh` - Generates directory trees and consolidates file contents

- `git/` - Git automation scripts
  - `create_github_repo.sh` - Sets up new GitHub repositories
  - `pushpull.sh`, `syncall.sh`, `syncdirs.sh` - Various git sync utilities
  - `startwiki.sh` - Wiki startup automation

- `lib/` - Shared library files
  - `bash-template.sh` - Template for new bash scripts
  - `colors.sh` - Terminal color definitions and utilities

- `linux/` - Linux-specific utilities
  - `toggle_touchscreen.sh` - Interactive script to enable/disable touchscreen input

- `updates/` - System update utilities
  - `update_servers.sh` - Automates server updates

## Prerequisites

- Bash shell (version 4.0 or higher recommended)
- Standard Unix utilities (`find`, `tree`, etc.)
- Git (for repository management scripts)
- For Windows users: Windows Subsystem for Linux (WSL) or Git Bash

## Installation

1. Clone the repository:
```bash
git clone https://github.com/stratofax/bash.git
```

2. Add the script directories to your PATH or create symlinks to the scripts you want to use:
```bash
# Example: Add to PATH in your .bashrc or .bash_profile
export PATH="$PATH:/path/to/bash/bin"
```

## Usage

Each script includes help information available via the `-h` or `--help` flag. Here are some common use cases:

### Managing Daily Logs
```bash
# Configure daylog settings
./daylog/daylog_cfg.sh

# Create/edit today's log
./daylog/daylog.sh
```

### Git Repository Management
```bash
# Sync all git repositories
./git/syncall.sh

# Create a new GitHub repository
./git/create_github_repo.sh
```

### File Management
```bash
# Generate a directory tree and file contents report
./files/savefiletree.sh -d /path/to/directory
```

### Linux Utilities
```bash
# Toggle touchscreen on/off
./linux/toggle_touchscreen.sh
```

## Coding Style

This repository follows the [Unofficial Shell Scripting Stylesheet](https://tldp.org/LDP/abs/html/unofficialst.html).

### Naming Conventions

* `variable_name` - Lower case with underscores for variables
* `CONSTANT_NAME` - Upper case for constants
* `E_ERROR_CODE` - Error codes prefixed with "E_"
* `FunctionName` - Upper case for function names

## Contributing

If you'd like to contribute to this repository, please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For questions or suggestions, please open an issue or contact the maintainer via GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
