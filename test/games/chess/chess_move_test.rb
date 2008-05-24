require 'test/unit'
require 'games/chess/move'

class ChessMoveTest < Test::Unit::TestCase
  include ValidationHelper
  
  def test_simple_move_fields
    move = Chess::Move.new(Point.new(4, 6), Point.new(4, 4))
    assert_equal Point.new(4, 6), move.src
    assert_equal Point.new(4, 4), move.dst
    assert_nil move.promotion
  end
  
  def test_promotion_move_fields
    move = Chess::Move.new(Point.new(3, 1), Point.new(3, 0), :promotion => :knight)
    assert_equal Point.new(3, 1), move.src
    assert_equal Point.new(3, 0), move.dst
    assert_equal :knight, move.promotion
  end
  
  def test_delta
    move = Chess::Move.new(Point.new(3, 6), Point.new(3, 0))
    assert_equal Point.new(0, -6), move.delta
  end
  
  def test_range
    move = Chess::Move.new(Point.new(2, 5), Point.new(6, 1))
    assert_equal [Point.new(2, 5), Point.new(3, 4), Point.new(4, 3), Point.new(5, 2)], move.range.to_a
  end
  
  def test_range_unlimited
    move = Chess::Move.new(Point.new(2, 5), Point.new(6, 0))
    assert_not_nil move.range
  end
end
