# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'interaction/match'
require_bundle 'engines', 'engine'

class XBoardEngine < Engine
  include Plugin
  
  plugin :name => 'XBoard Engine Protocol',
         :protocol => 'XBoard',
         :interface => :engine,
         :bundle => 'engines'
  
  FEATURES = %w(ping setboard playother san usermove time draw sigint sigterm
                reuse analyze myname variants colors ics name pause done)
  
  def setup
    super
    send_command "xboard"
    send_command "protover 2"
    send_command "nopost"
  end
  
  def on_move(data)
    text = @serializer.serialize(data[:move], data[:old_state])
    send_command text
    unless @playing
      send_command "go"
      @playing = true
    end
  end

  
  def on_engine_start
    send_command "new"
    send_command "force"
    if @color == :white
      send_command "go"
      @playing = true
    end
  end

  def on_command_feature(*args)
    args.each do |arg|
      if arg =~ /^(\S+)=(\S+)$/
        feature = $1
        value = $2[1...-1]
        if FEATURES.include?(feature)
          @features[feature] = value == '1' ? true : value
          send_command "accepted #{feature}"
        else
          send_command "rejected #{feature}"
        end
      end
    end
  end
  
  def on_command_move(move)
    move = @serializer.deserialize(move, @match.state)
    if move
      @match.move(self, move)
    end
  end
  
  def extra_command(text)
    if text =~ /^My move is: (.*)$/
      on_command_move($1)
    end
  end
  
  def on_close(data)
    send_command "quit"
  end
end
