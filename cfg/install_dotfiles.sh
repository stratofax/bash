#!/usr/bin/env bash
############################################################
# Configure my dotfiles repo on a new computer
############################################################

# turn on output for debugging
set -x
# turn off output for production
#set +x

# turn on unoffical bash strict mode
set -euo pipefail
############################################################

DTF_ALIAS="alias dotfiles=/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Go to your home directory
cd ~
# set up the dotfiles alias in .bashrc
#TARGET_FILE=$HOME/not_a_file
TARGET_FILE=$HOME/.bashrc

if [ -f "$TARGET_FILE" ]; then
  echo "Found file $TARGET_FILE"
  `cat "$TARGET_FILE"` | grep -q "$DTF_ALIAS"
  if [ $? -ne 0 ]; then
    echo "Updating $TARGET_FILE with line $DTF_ALIAS"
  else
    echo "Line $DTF_ALIAS already exists in $TARGET_FILE"
    cat "$TARGET_FILE"
  fi
else
  echo "File $TARGET_FILE not found."
fi

exit

echo "$DTF_ALIAS" >> $HOME/.bashrc
# now add it to the current bash session
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# avoid recursion
echo ".dotfiles" >> .gitignore
# clone your repo from GitHub
git clone --bare git@github.com:stratofax/dotfiles.git $HOME/.dotfiles
# check out the files from the repo
dotfiles checkout


