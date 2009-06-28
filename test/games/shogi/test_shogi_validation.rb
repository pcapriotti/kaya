require 'test/unit'
require 'games/all'
require 'helpers/validation_helper'

class TestShogiValidation < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @game = Game.get(:shogi)
    @state = @game.state.new
    @state.setup
    
    @validate = @game.validator.new(@state)
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
    
    @board[Point.new(0, 6)] = @game.piece.new(:white, :bishop)
    
    assert_valid 1, 8, 0, 6
  end
  
  def test_white_silver_move
    @board[Point.new(4, 4)] = @game.piece.new(:white, :silver)
    @state.turn = :white
    
    assert_valid 4, 4, 5, 3
    assert_valid 4, 4, 3, 3
    assert_valid 4, 4, 3, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 5, 5
    
    assert_not_valid 4, 4, 4, 3
    assert_not_valid 4, 4, 3, 4
    assert_not_valid 4, 4, 5, 4
    
    @board[Point.new(5, 3)] = @game.piece.new(:black, :rook)
    assert_valid 4, 4, 5, 3
  end
  
  def test_silver_move
    @board[Point.new(4, 4)] = @game.piece.new(:black, :silver)
    assert_valid 4, 4, 5, 5
    assert_valid 4, 4, 3, 5
    assert_valid 4, 4, 3, 3
    assert_valid 4, 4, 4, 3
    assert_valid 4, 4, 5, 3
    
    assert_not_valid 4, 4, 4, 5
    assert_not_valid 4, 4, 3, 4
    assert_not_valid 4, 4, 5, 4
    assert_not_valid 4, 4, 2, 3
    
    @board[Point.new(3, 5)] = @game.piece.new(:white, :rook)
    assert_valid 4, 4, 3, 5
  end
  
  def test_gold_move
    @board[Point.new(4, 4)] = @game.piece.new(:black, :gold)
    
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 3, 4
    assert_valid 4, 4, 5, 4
    assert_valid 4, 4, 3, 3
    assert_valid 4, 4, 4, 3
    assert_valid 4, 4, 5, 3
    
    assert_not_valid 4, 4, 5, 5
    assert_not_valid 4, 4, 3, 5
    assert_not_valid 4, 4, 2, 3
    
    @board[Point.new(4, 5)] = @game.piece.new(:white, :rook)
    assert_valid 4, 4, 4, 5
  end
  
  def test_white_gold_move
    @board[Point.new(4, 4)] = @game.piece.new(:white, :gold)
    @state.turn = :white
    
    assert_valid 4, 4, 4, 3
    assert_valid 4, 4, 3, 4
    assert_valid 4, 4, 5, 4
    assert_valid 4, 4, 3, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 5, 5
    
    assert_not_valid 4, 4, 5, 3
    assert_not_valid 4, 4, 3, 3
    
    @board[Point.new(4, 3)] = @game.piece.new(:black, :rook)
    assert_valid 4, 4, 4, 3
  end
  
  def test_king_move
    @board[Point.new(4, 4)] = @game.piece.new(:black, :king)
    
    assert_valid 4, 4, 5, 4
    assert_valid 4, 4, 5, 5
    assert_valid 4, 4, 4, 5
    assert_valid 4, 4, 3, 5
    
    assert_not_valid 4, 4, 3, 6
    assert_not_valid 4, 4, 2, 2
    assert_not_valid 4, 4, 4, 4
  end
  
  def test_bishop_move
    execute 2, 6, 2, 5
    execute 6, 2, 6, 3
    execute 1, 7, 7, 1
    execute 6, 3, 6, 4
    
    assert_not_valid 7, 1, 8, 1
    assert_valid 7, 1, 8, 0
  end
  
  def test_rook_move
    assert_valid 7, 7, 3, 7
    
    execute 6, 6, 6, 5
    execute 6, 2, 6, 3
    
    assert_not_valid 7, 7, 6, 6
  end
  
  def test_illegal_move
    @board[Point.new(4, 6)] = @game.piece.new(:white, :pawn)
    assert_valid 4, 8, 5, 7
    assert_valid 4, 8, 3, 7
    assert_not_valid 4, 8, 4, 7
  end
  
  def test_drop_with_empty_pool
    assert_not_valid @state.move_factory.drop(
      @state.piece_factory.new(:black, :rook),
      Point.new(4, 4))
  end
  
  def test_simple_drop
    piece = @state.piece_factory.new(:black, :rook)
    @state.pool(:black).add(@state.piece_factory.new(:black, :rook))
    assert_valid @state.move_factory.drop(piece, Point.new(4, 4))
      
    @state.board[Point.new(4, 4)] = @state.piece_factory.new(:white, :gold)
    assert_not_valid @state.move_factory.drop(piece, Point.new(4, 4))

    @state.board[Point.new(4, 4)] = @state.piece_factory.new(:black, :silver)
    assert_not_valid @state.move_factory.drop(piece, Point.new(4, 4))
  end
  
  def test_double_pawn_drop
    piece = @state.piece_factory.new(:black, :pawn)
    @state.pool(:black).add(piece)
    assert_not_valid @state.move_factory.drop(piece, Point.new(4, 4))
    @state.board[Point.new(4, 6)] = nil
    assert_valid @state.move_factory.drop(piece, Point.new(4, 4))
  end
  
  def test_last_row_pawn_drop
    piece1 = @state.piece_factory.new(:black, :pawn)
    piece2 = @state.piece_factory.new(:black, :horse)
    @state.pool(:black).add(piece1)
    @state.pool(:black).add(piece2)
    
    @state.board[Point.new(2, 6)] = nil
    @state.board[Point.new(2, 0)] = nil
    @state.board[Point.new(2, 1)] = nil
    @state.board[Point.new(2, 2)] = nil
    
    assert_not_valid @state.move_factory.drop(piece1, Point.new(2, 0))
    assert_valid @state.move_factory.drop(piece1, Point.new(2, 1))
    assert_not_valid @state.move_factory.drop(piece2, Point.new(2, 0))
    assert_not_valid @state.move_factory.drop(piece2, Point.new(2, 1))
    assert_valid @state.move_factory.drop(piece2, Point.new(2, 2))
  end

  def test_promotion_on_enter
    @state.board[Point.new(2, 6)] = nil
    @state.board[Point.new(2, 3)] = @game.piece.new(:black, :pawn)
    
    assert_valid 2, 3, 2, 2, :promote => true
    assert_valid 2, 3, 2, 2, :promote => false
    
    @state.board[Point.new(2, 3)] = nil
    @state.board[Point.new(2, 4)] = @game.piece.new(:black, :pawn)
    
    assert_valid 2, 4, 2, 3
    assert_valid 2, 4, 2, 3, :promote => false
    assert_not_valid 2, 4, 2, 3, :promote => true
  end
  
  def test_horse_promotion
    @state.board[Point.new(6, 3)] = @game.piece.new(:black, :horse)
    
    assert_valid 6, 3, 7, 1, :promote => true
  end
  
  def test_promotion_on_exit
    @state.board[Point.new(0, 2)] = @game.piece.new(:black, :rook)
    
    assert_valid 0, 2, 0, 4, :promote => true
    assert_valid 0, 2, 0, 4, :promote => false
  end
  
  def test_promotion_on_move_inside
    @state.board[Point.new(0, 2)] = @game.piece.new(:black, :rook)
    
    assert_valid 0, 2, 1, 2, :promote => true
    assert_valid 0, 2, 1, 2, :promote => false
  end
  
  def test_mandatory_promotion
    @state.board[Point.new(0, 6)] = nil
    @state.board[Point.new(0, 1)] = @game.piece.new(:black, :pawn)
    
    assert_valid 0, 1, 0, 0, :promote => true
    assert_not_valid 0, 1, 0, 0, :promote => false
    
    
    @state.board[Point.new(0, 2)] = @game.piece.new(:black, :horse)
    
    assert_valid 0, 2, 1, 0, :promote => true
    assert_not_valid 0, 2, 1, 0, :promote => false
    
    @state.board[Point.new(0, 2)] = nil
    @state.board[Point.new(0, 3)] = @game.piece.new(:black, :horse)
    
    assert_valid 0, 3, 1, 1, :promote => true
    assert_not_valid 0, 3, 1, 1, :promote => false
  end
  
  def test_promote_twice
    @state.board[Point.new(2, 3)] = @game.piece.new(:black, :promoted_lance)
    
#     assert_not_valid 2, 3, 2, 2, :promote => true
    assert_valid 2, 3, 2, 2, :promote => false
  end
end
