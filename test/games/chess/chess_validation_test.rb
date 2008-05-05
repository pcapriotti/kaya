require 'games/chess/state'
require 'games/chess/move'
require 'games/chess/piece'
require 'games/chess/validator'

class ChessValidationTest < Test::Unit::TestCase
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board)
    @state.setup
    @validate = Chess::Validator.new(@state)
  end
  
  def test_invalid_move
    move = Chess::Move.new(Point.new(32, 3), Point.new(3, 1))
    assert !@validate[move]
    
    move = Chess::Move.new(Point.new(3, 1), Point.new(32, 3))
    assert !@validate[move]
    
    move = Chess::Move.new(Point.new(4, 7), Point.new(4, 7))
    assert !@validate[move]
  end
  
  def test_e4
    e4 = Chess::Move.new(Point.new(4, 6), Point.new(4, 4))
    assert @validate[e4]
  end
  
  def test_e3
    e3 = Chess::Move.new(Point.new(4, 6), Point.new(4, 5))
    assert @validate[e3]
  end
  
  def test_e5
    e5 = Chess::Move.new(Point.new(4, 6), Point.new(4, 3))
    assert !@validate[e5]
  end
  
  def test_pawn_capture
    @board[Point.new(3, 5)] = @board[Point.new(3, 1)]
    move = Chess::Move.new(Point.new(4, 6), Point.new(3, 5))
    assert @validate[move]
  end
  
  def test_pawn_capture_on_empty_square
    move = Chess::Move.new(Point.new(4, 6), Point.new(3, 5))
    assert !@validate[move]
  end
  
  def test_e5_black
    @state.turn = :black
    e5 = Chess::Move.new(Point.new(4, 1), Point.new(4, 3))
    assert @validate[e5]
  end
  
  def test_king_moves
    @board.clear
    @board[Point.new(4, 4)] = Chess::Piece.new(:black, :king)
    @state.turn = :black
    
    move = Chess::Move.new(Point.new(4, 4), Point.new(5, 5))
    assert @validate[move]
    
    move = Chess::Move.new(Point.new(4, 4), Point.new(4, 5))
    assert @validate[move]
    
    move = Chess::Move.new(Point.new(4, 4), Point.new(4, 3))
    assert @validate[move]
    
    move = Chess::Move.new(Point.new(4, 4), Point.new(6, 4))
    assert !@validate[move]
  end
  
  def test_king_capture
    @board[Point.new(4, 6)] = @board[Point.new(4, 1)]
    move = Chess::Move.new(Point.new(4, 7), Point.new(4, 6))
    assert @validate[move]
    
    move = Chess::Move.new(Point.new(4, 7), Point.new(3, 7))
    assert !@validate[move]
  end
end
