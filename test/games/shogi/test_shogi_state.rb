require 'test/unit'
require 'games/shogi/state'
require 'helpers/validation_helper'

class TestShogiState < Test::Unit::TestCase
  include ValidationHelper

  def setup
    @board = Chess::Board.new(Point.new(9, 9))
    @state = Shogi::State.new(@board, Chess::Move, Chess::Piece)
  end
  
  def test_initialize
    assert_equal @board, @state.board
    assert_equal :black, @state.turn
  end
  
  def test_setup
    @state.setup
    
    (0...9).each do |i|
      assert_piece :black, :pawn, i, 7
      assert_piece :white, :pawn, i, 1
    end
    
    assert_piece :black, :lance, 0, 8
    assert_piece :black, :knight, 1, 8
    assert_piece :black, :king, 4, 8
    assert_piece :white, :silver, 6, 0
    assert_piece :white, :gold, 3, 0
    assert_piece :black, :gold, 5, 8
    assert_no_piece 6, 6
    assert_no_piece 3, 5
  end
  
  def test_colors
    assert_equal [:black, :white], @state.to_enum(:each_color).to_a
  end
  
  def test_row
    assert_equal 3, @state.row(3, :white)
    assert_equal 5, @state.row(3, :black)
  end
  
  def test_opposite_color
    assert_equal :white, @state.opposite_color(:black)
    assert_equal :black, @state.opposite_color(:white)
  end
end
