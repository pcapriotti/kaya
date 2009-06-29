# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class StateBase
  attr_accessor :turn
  attr_reader :board
  attr_reader :move_factory, :piece_factory

  def initialize(board, move_factory, piece_factory)
    @board = board
    @move_factory = move_factory
    @piece_factory = piece_factory
  end
  
  def initialize_copy(other)
    @board = other.board.dup
  end
  
  def try(move)
    tmp = dup
    tmp.perform! move
    yield tmp
  end
  
  def basic_move(move)
    captured = @board[move.dst]
    @board[move.dst] = @board[move.src]
    @board[move.src] = nil
    captured
  end
  
  def promote_on!(p, type)
    if @board[p]
      @board[p] = piece_factory.new(@board[p].color, type)
    end
  end
  
  def to_s
    [@board.to_s,
     "turn #{@turn.to_s}"].join("\n")
  end

  def ==(other)
    @board == other.board &&
      @turn == other.turn
  end
end
