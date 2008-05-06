require 'test/unit'
require 'games/chess/chess'
require 'helpers/validation_helper'

class ChessPerformMovesTest < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board)
    @validate = Chess::Validator.new(@state)
    
    @state.setup
  end
  
  def test_simple_move
    execute 6, 7, 5, 5
    
    assert_equal Chess::Piece.new(:white, :knight), 
                 @board[Point.new(5, 5)]
    assert_nil @state.board[Point.new(6, 7)]
    assert_nil @state.en_passant_square
    assert_equal :black, @state.turn
  end
  
  def test_en_passant_push
    execute 4, 6, 4, 4
    
    assert_equal Chess::Piece.new(:white, :pawn),
                 @board[Point.new(4, 4)]
    assert_nil @state.board[Point.new(4, 6)]
    assert_equal Point.new(4, 5), @state.en_passant_square
    assert_equal :black, @state.turn
  end
  
  def test_en_passant_capture
    execute 4, 6, 4, 4
    execute 0, 1, 0, 2
    execute 4, 4, 4, 3
    execute 3, 1, 3, 3
    execute 4, 3, 3, 2 
    
    assert_equal Chess::Piece.new(:white, :pawn),
                 @board[Point.new(3, 2)]
    assert_nil @board[Point.new(4, 3)]
    assert_nil @board[Point.new(3, 3)]
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
    execute 0, 1, 0, 0, :promotion => :rook
    
    assert_equal Chess::Piece.new(:white, :rook),
                 @board[Point.new(0, 0)]
  end
  
  def test_promotion_capture
    execute 0, 6, 0, 4 # a4
    execute 1, 1, 1, 3 # b5
    execute 0, 4, 1, 3 # axb5
    execute 0, 1, 0, 2 # a6
    execute 1, 3, 0, 2 # bxa6
    execute 1, 0, 2, 2 # Nc6
    execute 0, 2, 0, 1 # a7
    execute 0, 0, 1, 0 # Rb8
    execute 0, 1, 1, 0, :promotion => :bishop
    
    assert_equal Chess::Piece.new(:white, :bishop),
                 @board[Point.new(1, 0)]
  end
end
