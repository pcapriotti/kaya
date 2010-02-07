# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'games/all'
require 'require_bundle'
require_bundle 'shogi', 'type'

class TestShogiNotation < Test::Unit::TestCase
  def setup
    @game = Game.get(:shogi)
    @notation = @game.notation
  end

  def test_point_to_coord
    assert_equal '6b', 
      @notation.point_to_coord(Point.new(3, 1))
    assert_equal '5e',
      @notation.point_to_coord(Point.new(4, 4))
  end
  
  def test_point_from_coord
    assert_equal Point.new(3, 1),
      @notation.point_from_coord('6b')
    assert_equal Point.new(4, 4),
      @notation.point_from_coord('5e')
  end
  
  def test_notation1
    notation = @notation.from_s('+L-4e')
    assert_not_nil notation
    assert_equal Promoted.new(:lance), notation[:type]
    assert_nil notation[:src]
    assert ! notation[:drop]
    assert_equal Point.new(5, 4), notation[:dst]
  end
  
  def test_notation2
    notation = @notation.from_s('7g7f')
    assert_not_nil notation
    assert_equal Point.new(2, 6), notation[:src]
    assert_equal Point.new(2, 5), notation[:dst]
    assert ! notation[:drop]
  end
end
