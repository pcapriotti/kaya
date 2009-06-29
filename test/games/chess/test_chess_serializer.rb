# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'games/all'
require 'helpers/validation_helper'

class TestChessSerializer < Test::Unit::TestCase
  include ValidationHelper

  def setup
    @game = Game.get(:chess)
    @simple = @game.serializer.new(:simple)
    @san = @game.serializer.new(:compact)
    @dec = @game.serializer.new(:decorated)
    @state = @game.state.new
    @validate = @game.validator.new(@state)
  end

  def test_simple_serialization
    @state.setup
    assert_equal 'e2e4', serialize(@simple, 4, 6, 4, 4)
    @state.board[Point.new(6, 1)] = @game.piece.new(:white, :pawn)
    assert_equal 'g7h8=R', serialize(@simple,
      @game.move.new(Point.new(6, 1), Point.new(7, 0), :promotion => :rook))
  end
  
  def test_san_serialization_pawn
    @state.setup
    assert_equal 'e4', serialize(@san, 4, 6, 4, 4)
    
    execute 4, 6, 4, 4
    assert_equal 'e5', serialize(@san, 4, 1, 4, 3)
    
    @state.setup
    @state.board[Point.new(3, 5)] = @game.piece.new(:black, :rook)
    assert_equal 'exd3', serialize(@san, 4, 6, 3, 5)
  end
  
  def test_san_serialization_rook
    @state.setup
    @state.board[Point.new(7, 6)] = nil
    assert_equal 'Rh5', serialize(@san, 7, 7, 7, 3)
    assert_equal 'Rxh7', serialize(@san, 7, 7, 7, 1)
  end
  
  def test_san_serialization_ambiguous
    @state.board[Point.new(0, 0)] = @game.piece.new(:white, :rook)
    @state.board[Point.new(7, 0)] = @game.piece.new(:white, :rook)
    @state.board[Point.new(0, 7)] = @game.piece.new(:white, :rook)
    @state.board[Point.new(7, 7)] = @game.piece.new(:white, :king)
    @state.board[Point.new(5, 5)] = @game.piece.new(:black, :king)
    
    assert_equal 'Rab8', serialize(@san, 0, 0, 1, 0)
    assert_equal 'R8a7', serialize(@san, 0, 0, 0, 1)
    
    @state.board[Point.new(1, 0)] = @game.piece.new(:black, :bishop)
    
    assert_equal 'Raxb8', serialize(@san, 0, 0, 1, 0)
  end
  
  def test_deserialize
    @state.setup
    assert_deserialize('e4', 4, 6, 4, 4)
    
    execute 4, 6, 4, 4
    assert_deserialize('e5', 4, 1, 4, 3)
  end
  
  def test_deserialize_promotion
    @state.setup
    @state.board[Point.new(6, 1)] = @game.piece.new(:white, :pawn)
    
    assert_deserialize('gxh8=B', 6, 1, 7, 0, :promotion => :bishop)
  end
  
  def test_deserialize_castling_king
    @state.setup
    @state.board[Point.new(5, 7)] = nil
    @state.board[Point.new(6, 7)] = nil
    
    assert_deserialize('0-0', 4, 7, 6, 7)
  end
  
  def test_deserialize_castling_queen
    @state.setup
    @state.board[Point.new(3, 7)] = nil
    @state.board[Point.new(2, 7)] = nil
    @state.board[Point.new(1, 7)] = nil
    
    assert_deserialize('0-0-0', 4, 7, 2, 7)
  end
  
  private
  
  def assert_deserialize(san, a, b, c, d, opts = {})
    move = unpack_move(a, b, c, d)
    move.promotion = opts[:promotion]
    @game.validator.new(@state)[move]
    move2 = @san.deserialize(san, @state)
    assert_equal move, move2
  end
end
