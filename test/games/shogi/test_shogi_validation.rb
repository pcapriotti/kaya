require 'test/unit'
require 'games/shogi/game'
require 'helpers/validation_helper'

class TestShogiValidation < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @game = Shogi::Game.new
    @state = @game.new_state
    @state.setup
    
    @validate = @game.new_validator(@state)
    @board = @state.board
  end
  
  def test_invalid_move
    assert_not_valid 32, 3, 3, 1
    assert_not_valid 3, 1, 32, 3
    assert_not_valid 4, 7, 4, 7
  end
  
  def test_black_pawn_push
    assert_valid 4, 6, 4, 5
  end

  def test_white_pawn_push
    @state.turn = :white
    assert_valid 4, 2, 4, 3
  end

  def test_invalid_black_push
    assert_not_valid 4, 6, 4, 4
    assert_not_valid 4, 6, 4, 3
  end
  
  
  def test_pawn_capture
    @board[Point.new(3, 5)] = @board[Point.new(3, 2)]
    assert_valid 3, 6, 3, 5
  end
  
  def test_invalid_chesslike_capture
    @board[Point.new(3, 5)] = @board[Point.new(3, 2)]
    assert_not_valid 4, 6, 3, 5
  end
  
  def test_lance_move
    @board[Point.new(0, 6)] = nil
    @board[Point.new(1, 7)] = nil
    @board[Point.new(1, 8)] = nil
    
    assert_valid 0, 8, 0, 4
    assert_valid 0, 8, 0, 2
    assert_not_valid 0, 8, 0, 1
    assert_not_valid 0, 8, 0, 0
    
    assert_not_valid 0, 8, 1, 8
    assert_not_valid 0, 8, 1, 7
  end
  
  def test_horse_move
    @board[Point.new(0, 6)] = nil
    
    assert_valid 1, 8, 0, 6
    assert_not_valid 1, 8, 2, 6
    assert_not_valid 1, 8, 3, 7
    
    @board[Point.new(0, 6)] = Chess::Piece.new(:white, :bishop)
    
    assert_valid 1, 8, 0, 6
  end
  
  def test_white_silver_move
    @board[Point.new(4, 4)] = Chess::Piece.new(:white, :silver)
    @state.turn = :white
    
    assert_valid 4, 4, 5, 3
    assert_valid 4, 4, 3, 3
    assert_valid 4, 4, 3, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 5, 5
    
    assert_not_valid 4, 4, 4, 3
    assert_not_valid 4, 4, 3, 4
    assert_not_valid 4, 4, 5, 4
    
    @board[Point.new(5, 3)] = Chess::Piece.new(:black, :rook)
    assert_valid 4, 4, 5, 3
  end
  
  def test_silver_move
    @board[Point.new(4, 4)] = Chess::Piece.new(:black, :silver)
    assert_valid 4, 4, 5, 5
    assert_valid 4, 4, 3, 5
    assert_valid 4, 4, 3, 3
    assert_valid 4, 4, 4, 3
    assert_valid 4, 4, 5, 3
    
    assert_not_valid 4, 4, 4, 5
    assert_not_valid 4, 4, 3, 4
    assert_not_valid 4, 4, 5, 4
    
    @board[Point.new(3, 5)] = Chess::Piece.new(:white, :rook)
    assert_valid 4, 4, 3, 5
  end
  
  def test_gold_move
    @board[Point.new(4, 4)] = Chess::Piece.new(:black, :gold)
    
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 3, 4
    assert_valid 4, 4, 5, 4
    assert_valid 4, 4, 3, 3
    assert_valid 4, 4, 4, 3
    assert_valid 4, 4, 5, 3
    
    assert_not_valid 4, 4, 5, 5
    assert_not_valid 4, 4, 3, 5
    
    @board[Point.new(4, 5)] = Chess::Piece.new(:white, :rook)
    assert_valid 4, 4, 4, 5
  end
  
  def test_white_gold_move
    @board[Point.new(4, 4)] = Chess::Piece.new(:white, :gold)
    @state.turn = :white
    
    assert_valid 4, 4, 4, 3
    assert_valid 4, 4, 3, 4
    assert_valid 4, 4, 5, 4
    assert_valid 4, 4, 3, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 5, 5
    
    assert_not_valid 4, 4, 5, 3
    assert_not_valid 4, 4, 3, 3
    
    @board[Point.new(4, 3)] = Chess::Piece.new(:black, :rook)
    assert_valid 4, 4, 4, 3
  end
  
  def test_king_move
    @board[Point.new(4, 4)] = Chess::Piece.new(:black, :king)
    
    assert_valid 4, 4, 5, 4
    assert_valid 4, 4, 5, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 3, 5
    
    assert_not_valid 4, 4, 3, 6
    assert_not_valid 4, 4, 2, 2
    assert_not_valid 4, 4, 4, 4
  end
  
  def test_illegal_move
    @board[Point.new(4, 6)] = Chess::Piece.new(:white, :pawn)
    assert_valid 4, 8, 5, 7
    assert_valid 4, 8, 3, 7
    assert_not_valid 4, 8, 4, 7
  end
  
  def test_drop_with_empty_pool
    assert_not_valid @state.new_drop(@state.new_piece(:black, :rook),
                                     Point.new(4, 4))
  end
  
  def test_simple_drop
    @state.pool(:black).add(@state.new_piece(:black, :rook))
    assert_valid @state.new_drop(@state.new_piece(:black, :rook),
                                 Point.new(4, 4))
  end
end
