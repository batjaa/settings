Git configurations
==================

### Configuring merge tool

1. Install [p4merge](http://www.perforce.com/downloads) (only P4MERGE: VISUAL MERGE TOOL)
2. Open $HOME/.gitconfig and add the following changes

  ```
  [diff]
    tool = p4merge
  [difftool "p4merge"]
    cmd = "p4merge.exe $LOCAL $REMOTE"
  [merge]
    tool = p4merge
  [mergetool "p4merge"]
    cmd = "p4merge.exe $BASE $LOCAL $REMOTE $MERGED"
    trustExitCode = true
    keepBackup = false
  ```
