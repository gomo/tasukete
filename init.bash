#!/usr/bin/env bash
# cd `dirname $0`

tasukete() {
  if [ "$1" = "" ]
  then
    echo -e "`bundle exec ~/tasukete/main.rb help`"
    return 0
  fi

  command=`bundle exec ~/tasukete/main.rb command $@`
  eval "$command"
}

alias _=tasukete
