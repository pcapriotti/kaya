require 'games/chess/state'
require 'games/chess/move'
require 'games/chess/piece'

class ChessValidationTest < Test::Unit::TestCase
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board)
    @state.setup
  end
  
  def test_e4
    e4 = Chess::Move.new(Point.new(4, 6), Point.new(4, 4))
    
    assert @state.validate!(e4)
  end
  
  def test_e3
    e3 = Chess::Move.new(Point.new(4, 6), Point.new(4, 5))
    assert @state.validate!(e3)
  end
  
  def test_e5
    e5 = Chess::Move.new(Point.new(4, 6), Point.new(4, 3))
    assert !@state.validate!(e5)
  end
end
