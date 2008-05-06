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
    move = unpack_move(6, 7, 5, 5)
    assert @validate[move]
    assert_nil move.type
    
    @state.perform! move
    
    assert_equal Chess::Piece.new(:white, :knight), 
                 @board[Point.new(5, 5)]
    assert_nil @state.board[Point.new(6, 7)]
    assert_nil @state.en_passant_square
    assert_equal :black, @state.turn
  end
  
  def test_en_passant_push
    move = unpack_move(4, 6, 4, 4)
    assert @validate[move]
    assert_equal :en_passant_trigger, move.type
    
    @state.perform! move
    
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
    
    assert_equal :white, @state.turn
    move = unpack_move(4, 3, 3, 2)
    assert @validate[move]
    assert_equal :en_passant_capture, move.type
    
    @state.perform! move
    
    assert_equal Chess::Piece.new(:white, :pawn),
                 @board[Point.new(3, 2)]
    assert_nil @board[Point.new(4, 3)]
    assert_nil @board[Point.new(3, 3)]
  end
end
