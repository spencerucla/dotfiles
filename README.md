# mah dotfiles

```sh
./setup
```

## (just some linux install notes)

```sh
# essentials
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim git rsync tmux tree htop silversearcher-ag fd-find

# chrome
sudo apt-get install libcurl3 # but this didn't work so had to run `sudo apt-get -f install`
sudo apt-get install libxss1 libappindicator1 libindicator7 # actually just libappindicator1
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb
# login to chrome to sync bookmarks
rm google-chrome-stable_current_amd64.deb

# adb
sudo apt-get install libc6:i386 libstdc++6:i386 android-tools-adb

# ssh
sudo apt-get install openssh-server
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""
ssh-copy-id <username>@<hostname>

# configs
sudo update-alternatives --config editor
```

## TODOs
- See TODOs in setup, .vimrc, aosp.sh
- Use "local" for all local variables?

### gitconfig

```
alias git-root='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

[alias]
    bhist = "!git --no-pager reflog $(git rev-parse --abbrev-ref HEAD)"
    bselect = "!branches=$(git branch) && branch=$(echo \"$branches\" | fzf --reverse +s +m) && git checkout $(echo \"$branch\" | sed \"s/.* //\")"
    copysha = "!git rev-parse HEAD | tr -d '\n' | pbcopy"
    current-branch = !git rev-parse --abbrev-ref HEAD 2> /dev/null | sed 's/^HEAD$//'
    fall = "!for remote in $(git remote); do echo "Fetching $remote"; git fetch "$remote"; done"
    fpop = !git stash show -p | git apply && git stash drop
    mb = !git merge-base HEAD $1
    rmdeleted = !git rm $(git ls-files --deleted)
#     undopush = push -f origin HEAD^:master # undo a git push
    upstream = rev-parse --abbrev-ref --symbolic-full-name @{u}
    # Logs
    glog = log -E -i --grep
    lg = log --graph --pretty=format:'%Cred%h%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
    sl = log --oneline --decorate --graph -20
    sla = log --oneline --decorate --graph --all -20
    slap = log --oneline --decorate --all --graph
    slp = log --oneline --decorate --graph

    # Show the diff between the latest commit and the current state
    diff-latest-curr = !"git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat"
    # Find branches containing commit
    fb = "!f() { git branch -a --contains $1; }; f"
    # Merge GitHub pull request on top of the `master` branch
    mpr = "!f() { \
        if [ $(printf \"%s\" \"$1\" | grep '^[0-9]\\+$' > /dev/null; printf $?) -eq 0 ]; then \
            git fetch origin refs/pull/$1/head:pr/$1 && \
            git rebase master pr/$1 && \
            git checkout master && \
            git merge pr/$1 && \
            git branch -D pr/$1 && \
            git commit --amend -m \"$(git log -1 --pretty=%B)\n\nCloses #$1.\"; \
        fi \
    }; f"
```
