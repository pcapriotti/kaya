require 'test/unit'
require 'games/chess/state'
require 'games/chess/piece'

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
  end
  
  private
  
  def assert_piece(color, type, x, y)
    assert_equal Chess::Piece.new(color, type), @board[Point.new(x, y)]
  end
end