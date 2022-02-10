#!/bin/bash
# Title:        aosp.sh
# Description:  bash aliases/functions for AOSP development
# Author:       Spencer Sutterlin
# Email:        spencerucla@gmail.com

alias al="adb logcat"
alias alg="adb logcat | grep"
alias aldg="adb logcat -d | grep"

# AOSP build
# repo init -u <url> -m=android.xml -b=$1
alias rs="repo sync -c -q -j4 --no-tags"
  # -l for local is useful if already have automatic (cron) sync'ed with -n
  # -d for detach is useful if topic branches were started with "repo start"
# TODO: cleanup, move to gitconfig as alias?
alias gpb="git branch -a | grep '\->'; repo forall . -c 'echo $REPO_RREV'"
alias mp="make -j24 2>&1 | tee ~/logs/build/last.log"

# AOSP adb
alias wait="adb wait-for-device"
alias arfr="adb reboot forced-recovery"
alias arb="adb reboot bootloader"
alias asik="adb shell input keyevent"
alias asit="adb shell input text"
alias asc="adb exec-out screencap -p > ~/Desktop/screencap.png" # https://stackoverflow.com/a/31401447
alias llog="tee ~/logs/logcat/$(date '+%Y-%m-%d-%H%M')_logcat.log"
alias all="adb logcat | llog"
alias ams="adb shell am start -n" # <package>/.<Activity>
alias adump="adb shell dumpsys" # [service|activity service <package>]
# setprop log.tag.<TAG> V|''
# settings get global <setting>
alias uart="cu -s 115200 -l /dev/ttyUSB2"
alias ulog="tee ~/logs/uart/$(date '+%Y-%m-%d-%H%M')_uart.log"
alias uartl="uart | ulog"

# TODO: move to gitconfig alias
# Git Push: "gp"
# Push to gerrit to correct branch, whatever default remote branch is
# Requires: must be run from inside existing repo
gp() {
  BRANCH=`repo forall . -c 'echo $REPO_RREV'`
  if [ -z "$BRANCH" ]; then
    echo "ERROR: branch name failed to parse"
  else
    git push $(git remote) HEAD:refs/for/$BRANCH
  fi
}

# Build setup: "settop"
# Requires: script must be run from top of code tree
settop() {
  export TOP=$(pwd)
  . build/envsetup.sh
  setpaths
}

# adb remount + disable-verity + reboot, k?
# Everything needed in order to adb remount
aardvark() {
  adb root
  adb disable-verity
  adb reboot
}

# adb root, remount, sync, reboot: "arrsr"
arrsr() {
  adb root
  adb remount
  adb sync
  adb reboot
}

# push frameworks, first cd $TOP/frameworks/base/services/ && mm
apushfw() {
  if [ -z "$OUT" ]; then
    echo "ERROR: OUT must be set"
  fi
  adb root
  adb remount
  adb push $OUT/system/framework/ /system/
  adb reboot
}

# install_busybox on android
install_busybox() {
  adb push ~/tools/android-bin/busybox /system/bin
  adb shell busybox --install /system/bin
}

# ==========

# AOSP code nav
alias T="tcd"
alias D="tcd device"
alias K="tcd kernel"
alias FB="tcd frameworks/base"
alias FN="tcd frameworks/native"
alias V="tcd vendor"

# Find code top: "code_top"
# If you keep all your code trees in any of the directories below (CODE_LOC#)
# this will return 0 and print $TOP of the code tree you're in
# TODO: use loop and $PWD
code_top() {
  CODE_LOC1=~/code/
  CODE_LOC2=~/trees/
  CODE_LOC3=/trees/
  if [[ $PWD == "$CODE_LOC1"* ]]; then
    TREE=`echo ${PWD:${#CODE_LOC1}} | cut -d / -f 1`
    echo "$CODE_LOC1$TREE"
    return 0
  elif [[ $PWD == "$CODE_LOC2"* ]]; then
    TREE=`echo ${PWD:${#CODE_LOC2}} | cut -d / -f 1`
    echo "$CODE_LOC2$TREE"
    return 0
  elif [[ $PWD == "$CODE_LOC3"* ]]; then
    TREE=`echo ${PWD:${#CODE_LOC3}} | cut -d / -f 1`
    echo "$CODE_LOC3$TREE"
    return 0
  else
    return 1
  fi
}

# Top cd: "tcd <dir>"
# Jump to dir within code tree
tcd() {
  CODE_TOP=`code_top`
  if [ $? -eq 0 ]; then
    cd $CODE_TOP/$1
  else
    echo "ERROR: not in a code tree"
    return 1
  fi
}
