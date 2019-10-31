Git configurations
==================

### Configuring merge tool

1. Install [p4merge](http://www.perforce.com/downloads) (only P4MERGE: VISUAL MERGE TOOL)
2. Open $HOME/.gitconfig and add the following changes

  ```
  [diff]
    tool = smerge
  [difftool "smerge"]
    cmd = "smerge $LOCAL $REMOTE"
  [merge]
    tool = smerge
  [mergetool "smerge"]
    cmd = "smerge $BASE $LOCAL $REMOTE $MERGED"
    trustExitCode = true
    keepBackup = false
  ```

some change