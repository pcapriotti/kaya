# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'interaction/match'

class GNUShogiEngine
  include Plugin
  include Observer
  include Player
  
  plugin :name => 'GNUShogi Engine Protocol',
         :protocol => 'GNUShogi',
         :interface => :engine

  attr_reader :name, :color
         
  def initialize(path, name, color, match, opts = {})
    @name = name
    @color = color
    @match = match
    @path = path
    @opts = opts
    @playing = false
    @serializer = @match.game.serializer.new(:simple)
    
    @engine = KDE::Process.new
    @engine.on(:readyReadStandardOutput) { process_input }
    @engine.on(:started) { on_started }
    @engine.on('finished(int, QProcess::ExitStatus)') { on_quit }
    
    @command_queue = []
  end
  
  def on_move(data)
    text = @serializer.serialize(data[:move], data[:old_state])
    send_command text
    unless @playing
      send_command "go"
      @playing = true
    end
  end
  
  def start
    @engine.working_directory = @opts[:workdir] if @opts[:workdir]
    @engine.output_channel_mode = KDE::Process::OnlyStdoutChannel
    @engine.set_program(@path, @opts[:args] || [])
    @engine.start
    
    @match.register(self)
    setup
  end
  
  def setup
    @match.observe(:started) do
      send_command "new"
      send_command "force"
      if @color == :black
        send_command "go"
        @playing = true
      end
    end
  end
  
  def send_command(text)
    if @engine.state == Qt::Process::Running
      begin
        os = Qt::TextStream.new(@engine)
        os << text << "\n"
        puts "> #{text}" if @opts[:debug]
      ensure
        os.flush
      end
    else
      @command_queue << text
    end
  end
  
  def process_input
    while @engine.can_read_line
      line = @engine.read_line.to_s
      line.gsub!(/\r?\n?$/, '')
      puts "< #{line}" if @opts[:debug]
      process_command(line)
    end
  end
  
  def process_command(text)
    args = text.split(/\s+/)
    cmd = args[0]
    m = "on_command_#{cmd}"
    if respond_to?(m)
      send(m, *args[1..-1])
    else
      extra_command(text)
    end
  end

  def on_command_move(move)

  end
  
  def extra_command(text)
    if text =~ /^[0-9]*\. (\.\.\.) (\S+)/
      move = @serializer.deserialize($2, @match.state)
      if move
        @match.move(self, move)
      end
    end
  end
  
  def on_started
    @command_queue.each do |cmd|
      send_command cmd
    end
    @command_queue = []
    
    @match.start(self)
  end
  
  def on_quit
  end
  
  def on_close(data)
    send_command "quit"
    @engine.kill
  end
end
