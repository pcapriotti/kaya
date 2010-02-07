# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'require_bundle'
require_bundle 'chess', 'state'
require_bundle 'chess', 'board'
require_bundle 'chess', 'move'
require_bundle 'chess', 'piece'
require_bundle 'chess', 'validator'
require 'helpers/validation_helper'
require 'enumerator'

class TestChessAttack < Test::Unit::TestCase
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board, Chess::Move, Chess::Piece)
    @state.setup
    @validate = Chess::Validator.new(@state)
  end
  
  def test_attacked_by_white_pawns
    assert !@validate.attacked?(Point.new(4, 6))
    assert @validate.attacked?(Point.new(4, 5))
  end
  
  def test_attacked_by_black_pawns
    assert @validate.attacked?(Point.new(6, 2))
    assert @validate.attacked?(Point.new(6, 3))
    
    assert !@validate.attacked?(Point.new(6, 2), @state.piece_factory.new(:black, :rook))
    assert @validate.attacked?(Point.new(6, 2), @state.piece_factory.new(:white, :rook))
  end
end
