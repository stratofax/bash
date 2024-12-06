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

# Go to your home directory
cd $HOME
# the update to .bashrc is deprecated because pulling the dotfiles from the repo will do the same
# set up the dotfiles alias in .bashrc 
# echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
# now add it to the current bash session
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# avoid recursion
echo ".dotfiles" >> .gitignore
# clone your repo from GitHub
git clone --bare git@github.com:stratofax/dotfiles.git $HOME/.dotfiles
# check out the files from the repo
dotfiles checkout
