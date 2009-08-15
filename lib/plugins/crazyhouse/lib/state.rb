# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require_bundle 'chess', 'state'

module Crazyhouse

class State < Chess::State
  def initialize(board, pool_factory, move_factory, piece_factory)
    super(board, move_factory, piece_factory)
    @pools = to_enum(:each_color).inject({}) do |res, c|
      res[c] = pool_factory.new
      res
    end
  end
  
  def initialize_copy(other)
    super
    @pools = to_enum(:each_color).inject({}) do |res, c|
      res[c] = other.pool(c).dup
      res
    end
  end
  
  def pool(color)
    @pools[color]
  end
  
  def perform!(move)
    if move.dropped
      pool(turn).remove(move.dropped)
      board[move.dst] = move.dropped
      switch_turn!
    else
      super(move)
    end
  end
  
  def capture_on!(p)
    @board[p].tap do |captured|
      if captured
        piece = piece_factory.new(turn, 
          Promoted.demote(captured.type))
        pool(turn).add(piece)
      end
    end
    super(p)
  end
end

end
