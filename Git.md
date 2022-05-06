# Reset to previous state before amend

Move the current head so that it's pointing at the old commit
Leave the index intact for redoing the commit.
HEAD@{1} gives you "the commit that HEAD pointed at before
it was moved to where it currently points at". Note that this is
different from HEAD~1, which gives you "the commit that is the
parent node of the commit that HEAD is currently pointing to."

```
git reset --soft HEAD@{1}
```

# Ignore a file that has already been committed

```sh
git update-index --skip-worktree
```
