# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'interaction/match'

module ICS

class ICSPlayer
  include Player
  include Observer
  
  attr_reader :color, :name
  
  # create a new ICS player playing with
  # the given color and using the given
  # output channel to send moves
  def initialize(out, color, serializer, name)
    @color = color
    @out = out
    @serializer = serializer
    @name = name
  end

  def on_move(data)
    text = @serializer.serialize(data[:move], data[:old_state])
    @out[text]
  end
  
  def on_back
    @out['back']
  end
  
  def on_forward
    @out['forward']
  end
  
  def allow_undo?(player, manager)
    # request undo
    @out['takeback']
    # disallow for now
    manager.undo(self, nil)
  end
end

end