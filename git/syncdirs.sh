#!/bin/bash

for dir in */; do 
  echo 
  echo "Directory >>> $dir"
  cd $dir 
  git status && git pull && git push
  cd ..
done
