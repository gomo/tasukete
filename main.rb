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
  gray: "\e[90m",

  bold: "\e[1m"
}.freeze

def ftext(*args)
  string = args.pop
  "#{args.map {|attr| ATTRIBUTES[attr] }.join}#{string}\e[0m"
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

  def desc?
    return false if @string.nil?

    @string.start_with?('-')
  end

  def name_length
    return 0 unless command?

    @name.length
  end

  def display(max_length, prev_right_padding)
    return ftext(:yellow, :bold, @string) if title?
    return "#{ftext(:cyan, @name).rjust(max_length, ' ')} => #{@command}" if command?
    return "#{' ' * prev_right_padding}#{ftext(:gray, @string.gsub(/\A\- */, ''))}" if desc?

    @string
  end

  def bind(*args)
    return '' unless command?

    matchies = @command.scan(/(\$\{.+?\})/)
    return @command if matchies.empty?

    command = @command
    matchies.each do |captures|
      cap = captures.first
      index = cap.gsub(/[^0-9]/, '').to_i
      command = command.gsub(/#{Regexp.quote(cap)}/, args[index] || '')
    end

    command
  end
end

class Main < Thor
  desc 'command NAME[, ...ARGS]', 'NAMEのコマンドを探して文字列を返します。引数は`$n`が合ったらバインド。残りはそのまま渡します。'
  def command(*args)
    name = args.shift
    row = tasukete_rows.find {|r| r.command? && r.name == name }
    return puts '' if row.nil?

    puts row.bind(*args)
  end

  desc 'help', 'ヘルプを表示'
  def help
    help = <<~HELP
      #{ftext(:green, :bold, 'tasukete')}
      #{ftext(:green, '========')}

      #{ftext(:green, 'Command List:')}
    HELP

    rows = tasukete_rows
    max_length = rows.map(&:name_length).max
    prev_right_padding = 0
    tasukete_rows.each do |row|
      disp = row.display(max_length, prev_right_padding)

      help = "#{help}  #{disp}\n"
      prev_right_padding = disp[/\A */].size
    end

    help = help.chomp

    help = <<~HELP
      #{help}

      #{ftext(:green, 'Setting path:')}
        #{ftext(:red, '~/.tasukete')}

    HELP

    puts help
  rescue StandardError => e
    puts e.message
  end

  private

    def tasukete_rows
      dir = Pathname.new(File.expand_path('~'))
      return [] unless dir.join('.tasukete').exist?

      dir.join('.tasukete').read.split("\n").map {|str| Row.new(str) }
    end
end

Main.start(ARGV)
