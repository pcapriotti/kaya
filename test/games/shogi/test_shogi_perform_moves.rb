require 'test/unit'
require 'games/shogi/game'
require 'helpers/validation_helper'

class TestShogiPerformMoves < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @game = Shogi::Game.new
    @state = @game.new_state
    @validate = @game.new_validator(@state)
    @board = @state.board
    
    @state.setup
  end
  
  def test_pawn_push
    execute 2, 6, 2, 5
    
    assert_piece :black, :pawn, 2, 5
    assert_no_piece 2, 6
    assert_equal :white, @state.turn
  end
end
