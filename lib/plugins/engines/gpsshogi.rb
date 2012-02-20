# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'interaction/match'
require_bundle 'engines', 'engine'

class GPSShogiEngine < Engine
  include Plugin
  
  plugin :name => 'GPSShogi Engine Protocol',
         :protocol => 'GPSShogi',
         :interface => :engine
  
  def on_move(data)
    text = @serializer.serialize(data[:move], data[:old_state])
    send_command text
  end
  
  def on_engine_start
    send_command "new"
    if @color == :black
      send_command "black"
      send_command "go"
    else
      send_command "white"
    end
  end
  
  def extra_command(text)
    if text =~ /^[0-9]*\. (\.\.\.) (\S+)/
      move = @serializer.deserialize($2, @match.state)
      if move
        @match.move(self, move)
      end
    end
  end
  
  def on_close(data)
    send_command "quit"
    @engine.kill
  end
  
  def allow_undo?(player, manager)
    # gpsshogi does not wait when you tell it to undo
    # so we stop it from playing before calling undo
    if @match.current_player == self
      warn "Please wait until GPSShogi moves before undoing."
    else
      send_command "force"
      send_command "undo"
      send_command "undo"
      if @color == :black
        send_command "black"
      else
        send_command "white"
      end
      manager.undo(self, 2)
    end
  end
end
