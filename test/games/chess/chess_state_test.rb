require 'test/unit'
require 'games/chess/state'
require 'games/chess/piece'
require 'enumerator'
require 'helpers/validation_helper'

class ChessStateTest < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board, Chess::Move, Chess::Piece)
  end
  
  def test_board
    assert_same @board, @state.board
  end
  
  def test_setup
    @state.setup
    
    assert_piece :white, :pawn, 4, 6
    assert_piece :white, :pawn, 2, 6
    assert_piece :black, :pawn, 2, 1
    assert_piece :black, :pawn, 7, 1
    
    assert_piece :white, :queen, 3, 7
    assert_piece :black, :bishop, 5, 0
    assert_piece :black, :rook, 0, 0
    
    assert_piece :white, :knight, 6, 7
    assert_piece :white, :knight, 1, 7
    assert_piece :black, :knight, 6, 0
    assert_piece :black, :knight, 1, 0
  end
  
  def test_row
    assert_equal 2, @state.row(2, :black)
    assert_equal 5, @state.row(2, :white)
  end
  
  def test_colors
    assert_equal [:white, :black], @state.to_enum(:each_color).to_a
  end
  
  def test_opposite_turn
    assert_equal :white, @state.opposite_turn(:black)
    assert_equal :black, @state.opposite_turn(:white)
  end
  
  def test_king_starting_position
    assert_equal Point.new(4, 7), @state.king_starting_position(:white)
    assert_equal Point.new(4, 0), @state.king_starting_position(:black)
  end
  
  def test_direction
    assert_equal Point.new(0, -1), @state.direction(:white)
    assert_equal Point.new(0, 1), @state.direction(:black)
  end
  
  def test_dup
    other = @state.dup
    assert_not_same @state, other
    assert_not_same @state.board, other.board
    assert_not_same @state.castling_rights, other.castling_rights
  end
  
  def test_new_piece
    piece_factory = mock('piece factory') do |m|
      m.expects(:new).with(:white, :knight)
    end
    @state = Chess::State.new(@board, Chess::Move, piece_factory)
    @state.new_piece(:white, :knight)
  end
end
