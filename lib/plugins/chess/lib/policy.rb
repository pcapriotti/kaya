# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Chess
  class Policy
    attr_accessor :promotion
    
    def initialize(move_factory)
      @move_factory = move_factory
      @promotion = :queen
    end
    
    def movable?(state, p)
      piece = state.board[p]
      return false unless piece 
      if piece.color == state.turn
        :movable
      else
        :premovable
      end
    end
    
    def droppable?(state, color, index)
      if color == state.turn
        :droppable
      else
        :predroppable
      end
    end
    
    def new_move(state, src, dst, opts = {})
      @move_factory.new(src, dst, opts.merge(:promotion => @promotion))
    end
  end
end
