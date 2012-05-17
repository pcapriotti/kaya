# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/state_base'
require 'point'
require_bundle 'shogi', 'type'

module Shogi
  class State < StateBase
    def initialize(board, pool_factory, move_factory, piece_factory)
      super(board, move_factory, piece_factory)
      @pools = to_enum(:each_color).inject({}) do |res, c|
        res[c] = pool_factory.new
        res
      end
      @turn = :black
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
    
    def setup
      each_color do |color|
        (0...@board.size.x).each do |i|
          @board[Point.new(i, row(2, color))] = piece_factory.new(color, :pawn)
        end
        
        r = row(0, color)
        set_piece = lambda do |x, type|
          @board[Point.new(x, r)] = piece_factory.new(color, type)
        end
        set_piece[0, :lance]
        set_piece[1, :horse]
        set_piece[2, :silver]
        set_piece[3, :gold]
        set_piece[4, :king]
        set_piece[5, :gold]
        set_piece[6, :silver]
        set_piece[7, :horse]
        set_piece[8, :lance]
        
        r = row(1, color)
        @board[Point.new(r, r)] = piece_factory.new(color, :rook)
        @board[Point.new(@board.size.x - r - 1, r)] = piece_factory.new(color, :bishop)
      end
    end
    
    def each_color(&blk)
      yield :black
      yield :white
    end
    
    def row(i, color)
      color == :black ? @board.size.y - 1 - i : i
    end
    
    def col(i, color)
      color == :black ? i : @board.size.x - 1 - i
    end

    def opposite_color(color)
      color == :black ? :white : :black
    end
    
    def direction(color)
      Point.new(0, color == :black ? -1 : 1)
    end
    
    def perform!(move)
      if move.dropped
        pool(turn).remove(move.dropped)
        board[move.dst] = move.dropped
      else
        captured = basic_move(move)
        if move.promote?
          board[move.dst] = promoted(board[move.dst])
        end
        
        if captured
          piece = piece_factory.new(turn, 
            Promoted.demote(captured.type))
          pool(turn).add(piece)
        end
      end
      switch_turn!
    end
    
    def switch_turn!
      @turn = opposite_color(@turn)
    end
    
    def in_promotion_zone?(p, color)
      (row(6, color) <=> p.y) != (color == :black ? -1 : 1)
    end
    
    def capture_square(move)
      move.dst
    end
    
    def promoted(piece)
      piece_factory.new(
        piece.color,
        Promoted.promote(piece.type))
    end
  end
end

module MiniShogi
  class State < Shogi::State

    def setup
      each_color do |color|

        r = row(0, color)
        set_piece = lambda do |x, type|
          @board[Point.new(x, r)] = piece_factory.new(color, type)
        end
        set_piece[col(0,color), :king]
        set_piece[col(1,color), :gold]
        set_piece[col(2,color), :silver]
        set_piece[col(3,color), :bishop]
        set_piece[col(4,color), :rook]

        r = row(1, color)
        set_piece[col(0,color), :pawn]
      end
    end

    def in_promotion_zone?(p, color)
      (row(4, color) <=> p.y) != (color == :black ? -1 : 1)
    end

  end
end

module GoroGoroShogi
  class State < Shogi::State
    
    def setup
      each_color do |color|

        r = row(0, color)
        set_piece = lambda do |x, type|
          @board[Point.new(x, r)] = piece_factory.new(color, type)
        end
        set_piece[col(0,color), :silver]
        set_piece[col(1,color), :gold]
        set_piece[col(2,color), :king]
        set_piece[col(3,color), :gold]
        set_piece[col(4,color), :silver]

        r = row(2, color)
        set_piece[col(1,color), :pawn]
        set_piece[col(2,color), :pawn]
        set_piece[col(3,color), :pawn]
      end
    end

    def in_promotion_zone?(p, color)
      (row(5, color) <=> p.y) != (color == :black ? -1 : 1)
    end

  end
end
