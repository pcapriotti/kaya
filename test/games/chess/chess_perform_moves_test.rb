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
                 @state.board[Point.new(5, 5)]
    assert_nil @state.board[Point.new(6, 7)]
  end
end
