#!/usr/bin/env ruby

require 'thor'
require 'pry'

ATTRIBUTES = {
  red: "\e[31m",
  green: "\e[32m",
  yellow: "\e[33m",
  magenta: "\e[35m",
  cyan: "\e[36m",
  light_green: "\e[92m",

  bold: "\e[1m",
}

def test_attr(*args)
  string = args.pop
  "#{args.map{|attr| ATTRIBUTES[attr] }.join}#{string}\e[0m"
end


class Row
  attr_reader :name

  def initialize(string)
    if string.include?(' => ')
      @name, @command = string.split(' => ')
    else
      @string = string
    end
  end

  def command?
    @string.nil?
  end

  def title?
    return false if @string.nil?

    @string.start_with?('#')
  end

  def name_length
    return 0 unless command?

    @name.length
  end

  def display(max_length)
    return test_attr(:yellow, :bold, @string) if title?
    return @string unless command?

    "#{test_attr(:cyan, @name.rjust(max_length, ' '))} => #{@command}"
  end
end

class Main < Thor
  desc 'command NAME[, ...ARGS]', 'NAMEのコマンドを探して文字列を返します。引数は`$n`が合ったらバインド。残りはそのまま渡します。'
  def command(*args)
    puts "echo #{args.join(' ')}"
  end

  desc 'help', 'ヘルプを表示'
  def help
    help = <<~HELP
      #{test_attr(:green, :bold, 'tasukete')}
      #{test_attr(:green, '========')}

      #{test_attr(:green, 'Usage:')}
        tasukete COMMAND_NAME
        _ COMMAND_NAME

        Executes a registered command.

      #{test_attr(:green, 'Command List:')}
    HELP

    rows = tasukete_rows
    max_length = rows.map(&:name_length).max
    tasukete_rows.each do |row|
      help = "#{help}  #{row.display(max_length)}\n"
    end

    help = <<~HELP
      #{help}

      #{test_attr(:green, 'Register:')}
        If you want to register new command, Add to #{test_attr(:red, '~/.tasukete')} file like below:

        hello_command => echo "hello!"

    HELP

    puts help
  rescue StandardError => e
    puts e.message
  end

  private

    def tasukete_rows
      dir = Pathname.new(File.expand_path('~'))
      return [] unless dir.join('.tasukete').exist?

      dir.join('.tasukete').read.split("\n").map{|str|  Row.new(str) }
    end
end

Main.start(ARGV)
