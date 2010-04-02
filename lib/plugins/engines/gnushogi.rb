# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'interaction/match'
require_bundle 'engines', 'engine'

class GNUShogiEngine < Engine
  include Plugin
  
  plugin :name => 'GNUShogi Engine Protocol',
         :protocol => 'GNUShogi',
         :interface => :engine

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
    if @color == :black
      send_command "go"
      @playing = true
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
end
