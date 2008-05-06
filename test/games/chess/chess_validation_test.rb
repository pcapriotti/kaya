require 'test/unit'
require 'games/chess/state'
require 'games/chess/board'
require 'games/chess/move'
require 'games/chess/piece'
require 'games/chess/validator'
require 'helpers/validation_helper'
require 'enumerator'

class ChessValidationTest < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board)
    @state.setup
    @validate = Chess::Validator.new(@state)
  end
  
  def test_invalid_move
    assert_not_valid 32, 3, 3, 1
    assert_not_valid 3, 1, 32, 3
    assert_not_valid 4, 7, 4, 7
  end
  
  def test_pawn_push
    assert_valid 4, 6, 4, 4
    assert_valid 4, 6, 4, 5
  end
  
  def test_invalid_push
    assert_not_valid 4, 6, 4, 3
  end
  
  def test_pawn_capture
    @board[Point.new(3, 5)] = @board[Point.new(3, 1)]
    assert_valid 4, 6, 3, 5
  end
  
  def test_invalid_pawn_capture
    assert_not_valid 4, 6, 3, 5
  end
  
  def test_black_pawn_push
    @state.turn = :black
    assert_valid 4, 1, 4, 2
    assert_valid 4, 1, 4, 3
  end
  
  def test_king_moves
    @board.clear
    @board[Point.new(4, 4)] = Chess::Piece.new(:black, :king)
    @state.turn = :black
    
    assert_valid 4, 4, 5, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 4, 3
    assert_not_valid 4, 4, 6, 4
  end
  
  def test_king_capture
    @board[Point.new(4, 6)] = @board[Point.new(4, 1)]
    assert_valid 4, 7, 4, 6
    assert_not_valid 4, 7, 3, 7
  end
  
  def test_bishop_moves
    @board.clear
    @board[Point.new(4, 4)] = Chess::Piece.new(:white, :bishop)
    @board[Point.new(4, 5)] = Chess::Piece.new(:white, :pawn)
    @board[Point.new(6, 6)] = Chess::Piece.new(:white, :rook)
    @board[Point.new(2, 2)] = Chess::Piece.new(:black, :rook)
    
    assert_valid 4, 4, 5, 5
    assert_valid 4, 4, 2, 2
    assert_not_valid 4, 4, 1, 1
    assert_valid 4, 4, 1, 7
    assert_not_valid 4, 4, 6, 6
    assert_not_valid 4, 4, 6, 4
    assert_not_valid 4, 4, 3, 6
  end
  
  def test_rook_moves
    @board.clear
    @board[Point.new(4, 4)] = Chess::Piece.new(:white, :rook)
    @board[Point.new(5, 5)] = Chess::Piece.new(:white, :pawn)
    @board[Point.new(6, 4)] = Chess::Piece.new(:white, :bishop)
    @board[Point.new(4, 1)] = Chess::Piece.new(:black, :queen)
    
    assert_valid 4, 4, 4, 5
    assert_not_valid 4, 4, 3, 3
    assert_valid 4, 4, 4, 1
    assert_not_valid 4, 4, 4, 0
    assert_valid 4, 4, 5, 4
    assert_not_valid 4, 4, 6, 4
    assert_not_valid 4, 4, 7, 4
    assert_not_valid 4, 4, 3, 6
  end
  
  def test_queen_moves
    @board.clear
    @board[Point.new(4, 4)] = Chess::Piece.new(:white, :queen)
    @board[Point.new(2, 2)] = Chess::Piece.new(:white, :pawn)
    @board[Point.new(6, 4)] = Chess::Piece.new(:white, :bishop)
    @board[Point.new(4, 1)] = Chess::Piece.new(:black, :queen)
    
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 5, 5
    assert_not_valid 4, 4, 2, 2
    assert_not_valid 4, 4, 1, 1
    assert_not_valid 4, 4, 2, 3
    assert_not_valid 4, 4, 6, 4
    assert_valid 4, 4, 4, 1
    assert_not_valid 4, 4, 4, 0
    assert_valid 4, 4, 4, 2
    assert_valid 4, 4, 7, 7
    assert_not_valid 4, 4, 4, 8
  end
  
  def test_knight_moves
    @board.clear
    @board[Point.new(4, 4)] = Chess::Piece.new(:white, :knight)
    @board[Point.new(2, 2)] = Chess::Piece.new(:white, :pawn)
    @board[Point.new(6, 4)] = Chess::Piece.new(:white, :bishop)
    @board[Point.new(5, 2)] = Chess::Piece.new(:black, :queen)
    @board[Point.new(3, 6)] = Chess::Piece.new(:white, :queen)
    
    assert_valid 4, 4, 5, 6
    assert_valid 4, 4, 5, 2
    assert_valid 4, 4, 3, 2
    assert_valid 4, 4, 2, 5
    assert_not_valid 4, 4, 3, 6
    assert_not_valid 4, 4, 2, 4
    assert_not_valid 4, 4, 5, 4
    assert_not_valid 4, 4, 6, 4
    assert_not_valid 4, 4, 2, 4
    assert_not_valid 4, 4, 6, 6
  end
  
  def test_en_passant_push
    move = unpack_move(4, 6, 4, 4)
    assert @validate[move]
    
    assert_equal :en_passant_trigger, move.type
  end
  
  def test_en_passant_capture
    execute 4, 6, 4, 4
    execute 0, 1, 0, 2
    execute 4, 4, 4, 3
    execute 3, 1, 3, 3
    
    assert_equal :white, @state.turn
    move = unpack_move(4, 3, 3, 2)
    assert @validate[move]
    assert_equal :en_passant_capture, move.type
  end
  
  def test_late_en_passant_capture
    execute 4, 6, 4, 4
    execute 0, 1, 0, 2
    execute 4, 4, 4, 3
    execute 3, 1, 3, 3
    execute 0, 6, 0, 5
    execute 0, 2, 0, 3
    
    assert_not_valid 4, 3, 3, 2
  end
  
  def test_promotion
    execute 0, 6, 0, 4 # a4
    execute 1, 1, 1, 3 # b5
    execute 0, 4, 1, 3 # axb5
    execute 0, 1, 0, 2 # a6
    execute 1, 3, 0, 2 # bxa6
    execute 1, 0, 2, 2 # Nc6
    execute 0, 2, 0, 1 # a7
    execute 0, 0, 1, 0 # Rb8
    
    assert_valid 0, 1, 0, 0, :promotion => :rook
    assert_valid 0, 1, 1, 0, :promotion => :bishop
    assert_not_valid 0, 1, 0, 0
    assert_not_valid 0, 1, 1, 0
  end
  
  def test_king_side_castling
    assert_not_valid 4, 7, 6, 7
    
    @board[Point.new(5, 7)] = nil
    
    assert_not_valid 4, 7, 6, 7
    
    @board[Point.new(6, 7)] = nil
    
    assert_valid 4, 7, 6, 7
  end
  
  def test_castling_when_attacked
    @board[Point.new(5, 7)] = nil
    @board[Point.new(6, 7)] = nil
    @board[Point.new(4, 6)] = Chess::Piece.new(:black, :pawn)
    assert_not_valid 4, 7, 6, 7
  end
  
  def test_castling_checked
    @board[Point.new(5, 7)] = nil
    @board[Point.new(6, 7)] = nil
    @board[Point.new(3, 6)] = Chess::Piece.new(:black, :bishop)
    assert_not_valid 4, 7, 6, 7
  end
  
  def test_castling_king_moved
    @board[Point.new(5, 7)] = nil
    @board[Point.new(6, 7)] = nil
    execute 4, 7, 5, 7
    execute 0, 1, 0, 2
    execute 5, 7, 4, 7
    execute 0, 2, 0, 3
    
    assert_not_valid 4, 7, 6, 7
  end
  
  def test_castling_rook_moved
    @board[Point.new(5, 7)] = nil
    @board[Point.new(6, 7)] = nil
    execute 7, 7, 5, 7
    execute 0, 1, 0, 2
    execute 5, 7, 7, 7
    execute 0, 2, 0, 3
    
    assert_not_valid 4, 7, 6, 7
  end
  
  def test_castling_wrong_tower
    execute 6, 6, 6, 4
    execute 7, 1, 7, 3
    execute 6, 4, 7, 3
    execute 6, 1, 6, 3
    execute 7, 3, 7, 2
    execute 6, 3, 6, 4
    execute 7, 2, 7, 1
    execute 6, 4, 6, 5
    execute 7, 1, 6, 0, :promotion => :rook
    execute 6, 5, 7, 6
    execute 6, 0, 7, 0
    execute 7, 6, 6, 7, :promotion => :rook
    execute 0, 6, 0, 5
    execute 6, 7, 7, 7
    execute 7, 0, 7, 7
    execute 0, 1, 0, 2
    execute 5, 7, 7, 5
    execute 0, 2, 0, 3
    
    assert_not_valid 4, 7, 6, 7
  end
  
  def test_queen_side_castling
    @board[Point.new(3, 7)] = nil
    @board[Point.new(2, 7)] = nil
    @board[Point.new(1, 7)] = nil
    
    assert_valid 4, 7, 2, 7
  end
  
  def test_black_king_side_castling
    @board[Point.new(5, 0)] = nil
    @board[Point.new(6, 0)] = nil
    
    execute 0, 6, 0, 5
    
    assert_valid 4, 0, 6, 0
  end
  
  def test_black_queen_side_castling
    @board[Point.new(3, 0)] = nil
    @board[Point.new(2, 0)] = nil
    @board[Point.new(1, 0)] = nil
    
    execute 0, 6, 0, 5
    
    assert_valid 4, 0, 2, 0
  end
end
