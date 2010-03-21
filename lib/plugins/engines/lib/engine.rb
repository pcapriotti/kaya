# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# Helper class to subclass to implement an engine protocol.
# 
# Methods to implement:
# on_engine_start: called after the engine executable has been started
# on_command_*: called when a command of the form CMD ARG1 ARG2 ... is received
# extra_command: called when no on_command_* method can be called
# on_quit: called when the engine process terminates
# on_close: called when the match is closed
# allow_undo?: called by the match to perform an undo
# on_move: called when a new move is received
# 
class Engine
  include Observer
  include Player

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
    @engine.on(:ready_read_standard_output) { process_input }
    @engine.on(:started) { on_started }
    @engine.on(:finished) { on_quit }
    
    @command_queue = []
  end
  
  def start
    @engine.working_directory = @opts[:workdir] if @opts[:workdir]
    @engine.output_channel_mode = :only_stdout
      
    args = if @opts[:args]
      KDE::Process.split_args(@opts[:args])
    end
    args ||= []
    
    @engine.run(@path, args)
    
    @match.register(self)
    setup
  end
  
  def setup
    @match.on(:started) do
      on_engine_start
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
  
  def on_started
    @command_queue.each do |cmd|
      send_command cmd
    end
    @command_queue = []
    
    @match.start(self)
  end
  
  def on_quit
  end
  
  def allow_undo?(player, manager)
    manager.undo(player, nil)
  end
  
  def extra_command(text)
  end
end
