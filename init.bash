#!/usr/bin/env bash
# cd `dirname $0`

tasukete() {
  if [ "$1" = "" ]
  then
    echo -e "`ruby ~/tasukete/main.rb help`"
    return 0
  fi

  command=`ruby ~/tasukete/main.rb command $@`
  if [ -z "$command" ]; then
    echo -e "\033[0;31mMissing $1 command\033[0m"
    return 1
  fi

  eval "$command"
}

alias _=tasukete
