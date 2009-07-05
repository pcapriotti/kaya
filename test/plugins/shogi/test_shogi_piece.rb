# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require_bundle 'shogi', 'piece'
require_bundle 'shogi', 'type'

class TestShogiPiece < Test::Unit::TestCase
  def test_type_from_symbol
    assert_equal :lance, Shogi::Piece.type_from_symbol('L')
    assert_equal Promoted.new(:silver), Shogi::Piece.type_from_symbol('+S')
    assert_equal :gold, Shogi::Piece.type_from_symbol('G')
  end
  
  def test_symbol
    assert_equal 'R', Shogi::Piece.symbol(:rook)
    assert_equal '+B', Shogi::Piece.symbol(Promoted.new(:bishop))
    assert_equal '+N', Shogi::Piece.symbol(Promoted.new(:horse))
    assert_equal 'G', Shogi::Piece.symbol(:gold)
  end
  
  def test_equality
    assert Shogi::Piece.new(:white, :rook).eql?(
      Shogi::Piece.new(:white, :rook))
  end
end
