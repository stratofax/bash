# bash

Cross-platform bash scripts for Linux, Mac, and Windows (via WSL or Git Bash) computers. This repository contains a collection of utilities for automating common development tasks, managing git repositories, and maintaining system configurations.

## Repository Structure

- `ai/` - AI processing tools
  - `wav_2_txt.sh` - Transcribes .wav files using Whisper with timing metrics

- `cfg/` - System configuration utilities
  - `install_dotfiles.sh` - Sets up dotfiles on a new computer
  - `install_source_code_pro.sh` - Installs Adobe's Source Code Pro font

- `daylog/` - Daily logging tools
  - `diary.sh` - Interactive diary/journal tool with git integration
    - Creates and manages dated markdown entries
    - Supports custom editor configuration
    - Automatically handles git operations
    - Command-line options for customization
  - `daylog.sh` - Creates and manages daily log entries
  - `daylog_cfg.sh` - Configures daylog settings
  - `extract_tasks.sh` - Extracts task items from markdown files
  - `git_mv_to_month.sh` - Git operations for monthly organization
  - `yyyy_mm.sh` - Date formatting utility

- `files/` - File management utilities
  - `savefiletree.sh` - Generates directory trees and consolidates file contents
  - `move_list.sh` - Batch file moving utility
  - `recurse_subdirs.sh` - Recursive subdirectory operations
  - `remove_thumbs.sh` - Removes thumbnail files
  - `replace_in_filename.sh` - Batch filename string replacement utility
  - `resize_images.sh` - JPEG image resizing with aspect ratio preservation

- `git/` - Git automation scripts
  - `create_github_repo.sh` - Sets up new GitHub repositories
  - `pushpull.sh`, `syncall.sh`, `syncdirs.sh` - Various git sync utilities
  - `startwiki.sh` - Wiki startup automation

- `lib/` - Shared library files
  - `bash-template.sh` - Template for new bash scripts
  - `colors.sh` - Terminal color definitions and utilities

- `linux/` - Linux-specific utilities
  - `toggle_touchscreen.sh` - Interactive script to enable/disable touchscreen input

- `net/` - Network utilities
  - `dns_test.sh` - DNS lookup testing script
  - `dig_test.sh` - DNS lookup using dig command
  - `ns_test.sh` - Nameserver testing utility

## Prerequisites

- Bash shell (version 4.0 or higher recommended)
- Standard Unix utilities (`find`, `tree`, etc.)
- Git (for repository management scripts)
- ImageMagick (for image processing scripts)
- For Windows users: Windows Subsystem for Linux (WSL) or Git Bash

## Installation

### Clone the repository

```bash
git clone https://github.com/stratofax/bash.git
```

### Add the script directories to your PATH

Or create symlinks to the scripts you want to use.

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

# Replace spaces with underscores in filenames
./files/replace_in_filename.sh /path/to/directory

# Resize JPEG images to 900px height (default)
./files/resize_images.sh /path/to/images

# Create thumbnails at 150px height with custom suffix
./files/resize_images.sh /path/to/images -s thumb 150

# Resize with custom quality and suffix
./files/resize_images.sh /path/to/images 600 90 -s web
```

### Image Processing

```bash
# Resize JPEG images while maintaining aspect ratio
./files/resize_images.sh ~/photos                    # Default: 900px height, 85% quality
./files/resize_images.sh ~/photos 1200               # Custom height
./files/resize_images.sh ~/photos 800 95             # Custom height and quality
./files/resize_images.sh ~/photos -s thumb 150       # Thumbnails with custom suffix
./files/resize_images.sh ~/photos 600 85 -s web     # Web-optimized with custom suffix

# The script automatically:
# - Detects and uses ImageMagick (cross-platform)
# - Maintains aspect ratios
# - Creates organized output directories
# - Provides progress feedback with colored output
# - Handles errors gracefully
```

### AI Processing

```bash
# Transcribe all .wav files in current directory
./ai/wav_2_txt.sh
```

### Network Testing

```bash
# Test DNS resolution
./net/dns_test.sh example.com

# Test with specific nameserver
./net/ns_test.sh 8.8.8.8 example.com
```

### Linux Utilities

```bash
# Toggle touchscreen on/off
./linux/toggle_touchscreen.sh
```

### SSH

start-agent.sh -- start ssh-agent and load your SSH key

This script starts the `ssh-agent` if it's not already running and automatically loads your SSH key. This is particularly useful when connecting to your Mac via a remote session (e.g., SSH), where the ssh-agent may not be running.

**Important:** This script should be **sourced** (not executed) to ensure the ssh-agent environment variables are set in your current shell:

```bash
source path/to/bash/ssh/start-agent.sh
```

By default, the script loads `~/.ssh/id_ed25519`. You can specify a different key name using the `-n` option:

```bash
source path/to/bash/ssh/start-agent.sh -n id_rsa
```

Consider adding an alias to the remote computer to make this easier:

```bash
alias ssha='source path/to/bash/ssh/start-agent.sh'
```

## Coding Style

This repository follows best practices from the [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/index.html) and uses ShellCheck for code quality validation.

### Naming Conventions

- `variable_name` - Lower case with underscores for variables
- `CONSTANT_NAME` - Upper case for constants
- `E_ERROR_CODE` - Error codes prefixed with "E_"
- `FunctionName` - Upper case for function names

### Code Quality

All scripts use bash strict mode (`set -euo pipefail`) and can be validated with ShellCheck:

```bash
shellcheck script.sh
```

The repository includes `.shellcheckrc` configuration for external source validation.

## Contributing

If you'd like to contribute to this repository, please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For questions or suggestions, please open an issue or contact the maintainer via GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
