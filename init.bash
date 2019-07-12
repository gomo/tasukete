#!/usr/bin/env bash
# cd `dirname $0`

tasukete() {
  if [ "$1" = "" ]
  then
    echo -e "`ruby exec ~/tasukete/main.rb help`"
    return 0
  fi

  command=`ruby exec ~/tasukete/main.rb command $@`
  eval "$command"
}

alias _=tasukete
