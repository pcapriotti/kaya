require 'test/unit'
require 'games/chess/chess'
require 'helpers/animation_test_helper'

class TestChessAnimator < Test::Unit::TestCase
  include AnimationAssertions
  
  def setup
    @chess = Chess::Game.new
    @items = {
      Point.new(3, 4) => @chess.new_piece(:white, :king),
      Point.new(3, 1) => @chess.new_piece(:black, :king),
      Point.new(7, 7) => @chess.new_piece(:black, :queen)
    }
    @board = FakeBoard.new(@items)
    
    @animator = @chess.new_animator(@board)
    class << @animator
      include StubbedAnimations
    end
    @state = @chess.new_state
  end
  
  def test_null_warp
    @state.board[Point.new(3, 4)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(7, 7)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.warp(@state)
    assert_animation(:group, anim) do |args|
      assert_equal [], args
    end
  end
  
  def test_simple_warp
    @state.board[Point.new(4, 3)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(7, 7)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.warp(@state)
    assert_animation(:group, anim) do |args|
      assert_equal 2, args.size
      
      appear, disappear = args.sort
      assert_animation :instant_appear, appear
      assert_animation :instant_disappear, disappear
    end
  end
  
  def test_simple_noninstant_warp
    @state.board[Point.new(4, 3)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(7, 7)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.warp(@state, :instant => false)
    assert_animation(:group, anim) do |args|
      assert_equal 2, args.size
      
      appear, disappear = args.sort
      assert_animation :appear, appear
      assert_animation :disappear, disappear
    end    
  end
  
  def test_simple_forward
    move = @state.new_move(Point.new(7, 7), Point.new(5, 5))
    @state.board[Point.new(3, 4)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(5, 5)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.forward(@state, move)
    
    assert_animation(:sequence, anim) do |args|
      assert_equal 2, args.size
      
      warp, main = args.sort_by {|a| a.args.size }
      
      assert_animation(:group, warp) {|a| assert_equal [], a }
      assert_animation(:group, main) do |args|
        mov = args.find {|a| a.animation == :movement }
        assert_animation(:movement, mov) do |args|
          piece, src, dst = args
          assert_equal @chess.new_piece(:black, :queen), piece
          assert_equal Point.new(7, 7), src
          assert_equal Point.new(5, 5), dst
        end
      end
    end
  end
end
