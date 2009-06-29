# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'games/chess/piece'

class TestChessPiece < Test::Unit::TestCase
  def test_fields
    piece = Chess::Piece.new(:white, :bishop)
    assert_equal :bishop, piece.type
    assert_equal :white, piece.color
  end
  
  def test_equality
    assert_equal Chess::Piece.new(:white, :bishop), Chess::Piece.new(:white, :bishop)
    assert_not_equal Chess::Piece.new(:white, :bishop), Chess::Piece.new(:black, :bishop)
    assert_not_equal Chess::Piece.new(:white, :bishop), Chess::Piece.new(:white, :rook)
    assert_not_equal Chess::Piece.new(:white, :queen), Chess::Piece.new(:black, :king)
  end
  
  def test_name
    assert_equal "white bishop", Chess::Piece.new(:white, :bishop).name
    assert_equal "black pawn", Chess::Piece.new(:black, :pawn).name
    assert_equal "black knight", Chess::Piece.new(:black, :knight).name
  end
  
  def test_symbol
    assert_equal 'K', Chess::Piece.new(:white, :king).symbol
    assert_equal 'n', Chess::Piece.new(:black, :knight).symbol
    assert_equal 'N', Chess::Piece.new(:white, :knight).symbol
    assert_equal 'q', Chess::Piece.new(:black, :queen).symbol
    assert_equal 'R', Chess::Piece.new(:white, :rook).symbol
  end
  
  def test_same_color_of
    assert Chess::Piece.new(:white, :knight).same_color_of?(Chess::Piece.new(:white, :rook))
    assert Chess::Piece.new(:white, :bishop).same_color_of?(Chess::Piece.new(:white, :bishop))
    assert !Chess::Piece.new(:white, :pawn).same_color_of?(Chess::Piece.new(:black, :queen))
    assert !Chess::Piece.new(:white, :knight).same_color_of?(nil)
  end
end
