#!/usr/bin/env bash
# cd `dirname $0`

tasukete() {
  if [ "$@" = "" ]
  then
    `bundle exec main.rb help`
    exit 0
  fi

  command=`bundle exec main.rb command $@`
  eval "$command"
}

alias _="tasukete"