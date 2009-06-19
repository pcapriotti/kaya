require 'test/unit'
require 'games/games'
require 'games/all'
require 'helpers/validation_helper'

class TestShogiPerformMoves < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @game = Game.get(:shogi)
    @state = @game.state.new
    @validate = @game.validator.new(@state)
    @board = @state.board
    
    @state.setup
  end
  
  def test_pawn_push
    execute 2, 6, 2, 5
    
    assert_piece :black, :pawn, 2, 5
    assert_no_piece 2, 6
    assert_equal :white, @state.turn
  end
  
  def test_pawn_capture
    execute 2, 6, 2, 5
    execute 2, 2, 2, 3
    execute 2, 5, 2, 4
    execute 2, 3, 2, 4
    
    assert_piece :white, :pawn, 2, 4
    assert_no_piece 2, 3
    assert_no_piece 2, 2
    assert_no_piece 2, 5
    assert_no_piece 2, 6
  end
end
