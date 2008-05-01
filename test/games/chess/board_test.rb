require 'test/unit'
require 'games/chess/board'
require 'games/chess/point'

class BoardTest < Test::Unit::TestCase
  def setup
    @board = Board.new(Point.new(8, 8))
  end
  
  def test_empty_board
    assert_nil @board[Point.new(3, 4)]
    assert_nil @board[Point.new(1, 7)]
  end
  
  def test_out_of_board
    assert_nil @board[Point.new(9, 1)]
    assert_nil @board[Point.new(1, 10)]
    assert_nil @board[Point.new(32, 12)]
  end
  
  def test_set_then_get
    @board[Point.new(3, 4)] = 55
    assert_equal 55, @board[Point.new(3, 4)]
  end
  
  def test_set_out_of_board
    @board[Point.new(10, 2)] = 12
    assert_nil @board[Point.new(10, 2)]
  end
  
  def test_valid
    assert @board.valid?(Point.new(4, 5))
    assert !@board.valid?(Point.new(8, 2))
    assert !@board.valid?(Point.new(2, 8))
    assert !@board.valid?(Point.new(8, 8))
    assert !@board.valid?(Point.new(10, 3))
    assert @board.valid?(Point.new(7, 7))
  end
  
  def test_size
    assert_equal Point.new(8, 8), @board.size
    assert_equal Point.new(5, 23), Board.new(Point.new(5, 23)).size
  end
end
