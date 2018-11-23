# Contents
    - [Git and Gerrit](#Git and Gerrit)
        - [Random note about repo sync](#Git and Gerrit#Random note about repo sync)
        - [Git grep](#Git and Gerrit#Git grep)
        - [Signoff edit commit messages](#Git and Gerrit#Signoff edit commit messages)
        - [What branch to push to](#Git and Gerrit#What branch to push to)
        - [Reupload change to gerrit](#Git and Gerrit#Reupload change to gerrit)
        - [Track a remote branch](#Git and Gerrit#Track a remote branch)
        - [Cherry-picking fixes from another branch](#Git and Gerrit#Cherry-picking fixes from another branch)
        - [View commits since a commit](#Git and Gerrit#View commits since a commit)
        - [Find history since last common ancestor between 2 branches](#Git and Gerrit#Find history since last common ancestor between 2 branches)
        - [Git blame one line of a file](#Git and Gerrit#Git blame one line of a file)
        - [Show all file stat for commits that touched file](#Git and Gerrit#Show all file stat for commits that touched file)
        - [Kernel format checking](#Git and Gerrit#Kernel format checking)
        - [Applying patches](#Git and Gerrit#Applying patches)
    - [Repo Manifest](#Repo Manifest)
        - [Save known good manifest snapshot](#Repo Manifest#Save known good manifest snapshot)
        - [Revert back to known good manifest](#Repo Manifest#Revert back to known good manifest)
    - [Git repo remote management](#Git repo remote management)
        - [Push direct to specific remote](#Git repo remote management#Push direct to specific remote)
        - [Add different remote to a repo](#Git repo remote management#Add different remote to a repo)
        - [Query gerrit for my merged changes](#Git repo remote management#Query gerrit for my merged changes)

# Git and Gerrit

## Random note about repo sync
repo sync -j4 creates a new branch "(no branch)" and you have to do git checkout -b <new name> to save it

## Git grep
git grep <word> <path>

## Signoff edit commit messages
```sh
git rebase -i HEAD~#
# Choose "edit" instead of "pick"
# for each commit
git commit --amend -s
git rebase --continue
```

## What branch to push to
```sh
git branch -a | grep "\->"
```
It'll give "<remote>/<remote-branch>"
```sh
git push <remote> HEAD:refs/for/<remote-branch>
```

## Reupload change to gerrit
```sh
git add <files>
git commit --amend
git push <remote> HEAD:refs/for/<remote-branch>
```

## Track a remote branch
When you want changes you make to be merged with the stuff you pull
git remote show origin
git checkout --track -b branch_name --track origin/branch_name

## Cherry-picking fixes from another branch
git cherry-pick -x <commit-sha-from-fixed-branch>
git commit --amend
git push origin HEAD:refs/for/<new-branch>

## View commits since a commit
```sh
git log --oneline <sha>^..HEAD # (^ includes the commit specified)
```

## Find history since last common ancestor between 2 branches
```sh
git merge-base <branch1> <branch2>
git log --oneline <sha>^..HEAD
```

## Git blame one line of a file
git blame -L62,+1 <sha> <file>

## Show all file stat for commits that touched file
git log --stat --full-diff <path/file>

## Kernel format checking
For kernel formatting checking
```sh
git format-patch <remote>/<remote-branch>..<local-branch>
```
OR
```sh
git format-patch -n HEAD^
kernel/scripts/checkpatch.pl <patchname>
```

## Applying patches
```sh
git apply --check <patchname>
git am <patchname>
```
OR
```sh
git apply <patchname>
```
OR to do it in chunks
```sh
patch -p1 < <patchname>
```

# Repo Manifest

## Save known good manifest snapshot
```sh
repo manifest -r -o good_manifest_<date>.xml
```

## Revert back to known good manifest
```sh
repo init -m <good_manifest.xml>
repo sync -d # -c -q -j12 --no-tags
```

# Git repo remote management

## Push direct to specific remote
```sh
git push ssh://<username>@<gerrit-url>:<port>/<repo> HEAD:refs/for/<branch>
```

## Add different remote to a repo
```sh
git remote add <remote> ssh://<gerrit-url>:<port>/<repo>
git fetch <remote> <branch>
git checkout <branch>
...
git push <remote> HEAD:refs/for/<branch>
```

## Query gerrit for my merged changes
ssh -p 29418 <username>@<server> gerrit query owner:self status:merged --format json > changes.txt
