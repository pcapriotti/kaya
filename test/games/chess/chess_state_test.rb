require 'test/unit'
require 'games/chess/state'
require 'games/chess/piece'
require 'enumerator'

class ChessStateTest < Test::Unit::TestCase
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board)
  end
  
  def test_board
    assert_same @board, @state.board
  end
  
  def test_setup
    @state.setup
    
    assert_piece :white, :pawn, 4, 6
    assert_piece :white, :pawn, 2, 6
    assert_piece :black, :pawn, 2, 1
    assert_piece :black, :pawn, 7, 1
    
    assert_piece :white, :queen, 3, 7
    assert_piece :black, :bishop, 5, 0
    assert_piece :black, :rook, 0, 0
    
    assert_piece :white, :knight, 6, 7
    assert_piece :white, :knight, 1, 7
    assert_piece :black, :knight, 6, 0
    assert_piece :black, :knight, 1, 0
  end
  
  def test_row
    assert_equal 2, @state.row(2, :black)
    assert_equal 5, @state.row(2, :white)
  end
  
  def test_colors
    assert_equal [:white, :black], @state.to_enum(:each_color).to_a
  end
  
  private
  
  def assert_piece(color, type, x, y)
    assert_equal Chess::Piece.new(color, type), @board[Point.new(x, y)]
  end
end
