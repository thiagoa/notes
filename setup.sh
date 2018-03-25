#!/bin/bash

# Run this script from within the repo directory

rm .git/hooks/post-commit 2> /dev/null
ln -s $PWD/post-commit $PWD/.git/hooks/post-commit
