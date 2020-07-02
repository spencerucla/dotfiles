#!/bin/bash
# Title:        aosp.sh
# Description:  bash aliases/functions for AOSP development
# Author:       Spencer Sutterlin
# Email:        spencerucla@gmail.com

alias al="adb logcat"
alias alg="adb logcat | grep"
alias aldg="adb logcat -d | grep"

# AOSP build
alias rs="repo sync -c -q -j4 --no-tags"
  # -l for local is useful if already have automatic (cron) sync'ed with -n
  # -d for detach is useful if topic branches were started with "repo start"
# TODO: cleanup, move to gitconfig as alias?
alias gpb="git branch -a | grep '\->'; repo forall . -c 'echo $REPO_RREV'"
alias mp="mp 2>&1 | tee ~/logs/build/last.log"

# AOSP adb
alias wait="adb wait-for-device"
alias arfr="adb reboot forced-recovery"
alias arb="adb reboot bootloader"
alias asik="adb shell input keyevent"
alias asit="adb shell input text"
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
    git push origin HEAD:refs/for/$BRANCH
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

# install_busybox on android
install_busybox() {
  adb push ~/tools/android-bin/busybox /system/bin
  adb shell busybox --install /system/bin
}
