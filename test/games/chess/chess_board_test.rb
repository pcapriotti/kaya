require 'test/unit'
require 'games/chess/board'
require 'point'
require 'enumerator'

class BoardTest < Test::Unit::TestCase
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
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
    assert_equal Point.new(5, 23), Chess::Board.new(Point.new(5, 23)).size
  end
  
  def test_each_square
    assert_equal 64, @board.to_enum(:each_square).to_a.size
  end
  
  def test_each_item
    assert_equal [], @board.to_enum(:each_item).to_a
    
    @board[Point.new(4, 5)] = 74
    @board[Point.new(4, 7)] = 21
    @board[Point.new(3, 1)] = 78
    
    assert_equal [78, 74, 21], @board.to_enum(:each_item).to_a
  end
  
  def test_clear
    @board[Point.new(1, 7)] = 99
    assert_not_nil @board[Point.new(1, 7)]
    @board.clear
    assert_nil @board[Point.new(1, 7)]
  end
  
  def test_to_s
    class << x = Object.new
      def symbol
        'x'
      end
    end
    @board[Point.new(1, 7)] = x
    @board[Point.new(2, 6)] = x
    @board[Point.new(3, 6)] = x
    @board[Point.new(5, 5)] = x
    @board[Point.new(0, 0)] = x
    
    expected = <<EOF.chomp
  x            
    x x        
          x    
               
               
               
               
x              
EOF
    
    assert_equal expected, @board.to_s
  end
end
