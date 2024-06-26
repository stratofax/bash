# bash

Cross-platform bash scripts for Linux, Mac, and Windows computers.

## bash style guide

To keep things consistent, I use the [Unofficial Shell Scripting Stylesheet](https://tldp.org/LDP/abs/html/unofficialst.html).

### Naming Things

* `variable_name` -- lower case, underscore to separate words.
* `CONSTANT_NAME` -- a variable that you won't change (note that bash does not enforce this)
* `E_ERROR_CODE` -- an error code (constant): prefix with "E_"
* `FunctionName` -- Use Upper Case, no spaces

## Why bash?

The Bourne Again Shell (bash) is installed by default on almost every Linux distro, all Macs, and is even available on Windows. It's also available on most commercial Unix installations. This means bash is the closest thing there is to a universal shell.

The bash scripts in this repository are fully bash-compatible, but that doesn't mean they're POSIX-compatible.

I don't use bash as my primary shell -- I prefer fish. You might use another shell too: zsh, korn, whatever. When I'm writing scripts, though, I use bash. I just need to use the bash shebang at the top of the script file:

```bash
#!/bin/bash
```

This tells my computer, whatever OS it's running, to use the default bash interpreter to run my script.

If you'd like your bash scripts to use the first bash interpreter in your PATH, use this shebang line instead:

```bash
#!/usr/bin/env bash
```

This adds more complexity and flexibility to your configuration, but also more confusion. If you want to use multiple bash interpreters, you probably know how to do a global replace across an entire directory struture.

We're going to keep it simple here and stick with:

```bash
#!/bin/bash
```

## Bash tips and tricks: the wiki

In addition to handy bash scripts, there are also bash one-liners, aliases, custom prompts, links, and other goodies. If it's not a script file, but useful bash knowledge, I'll put it in this repo's [bash Wiki](https://github.com/stratofax/bash/wiki)

## Getting started

If you want to contribute to this repo, please contact me via GitHub.
