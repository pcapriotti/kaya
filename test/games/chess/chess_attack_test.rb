require 'test/unit'
require 'games/chess/state'
require 'games/chess/board'
require 'games/chess/move'
require 'games/chess/piece'
require 'games/chess/validator'
require 'helpers/validation_helper'
require 'enumerator'

class ChessAttackTest < Test::Unit::TestCase
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board, Chess::Move, Chess::Piece)
    @state.setup
    @validate = Chess::Validator.new(@state)
  end
  
  def test_attacked_by_white_pawns
    assert !@validate.attacked?(Point.new(4, 6))
    assert @validate.attacked?(Point.new(4, 5))
  end
  
  def test_attacked_by_black_pawns
    assert @validate.attacked?(Point.new(6, 2))
    assert @validate.attacked?(Point.new(6, 3))
    
    assert !@validate.attacked?(Point.new(6, 2), @state.new_piece(:black, :rook))
    assert @validate.attacked?(Point.new(6, 2), @state.new_piece(:white, :rook))
  end
end
