require 'test/unit'
require 'games/all'
require 'history'
require 'helpers/validation_helper'

class TestPGN < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @game = Game.get(:chess)
    @state = @game.state.new
    @state.setup
    @history = History.new(@state)
    @writer = @game.game_writer.new
  end
  
  def test_pgn_black_wins
    add_move 4, 6, 4, 4
    add_move 4, 1, 4, 3
    info = { :result => :black }
    
    expected = <<-END_OF_PGN
[Result "0-1"]
1.e4 e5 0-1
    END_OF_PGN
    
    assert_equal expected, @writer.write(info, @history)
  end
  
  def test_pgn_white_wins
    add_move 6, 7, 5, 5
    info = { :result => :white,
             :event => 'Oktoberfest',
             :players => { :white => 'Doe, John',
                           :black => 'Smith, Bob' } }
    
    expected = <<-END_OF_PGN
[Event "Oktoberfest"]
[White "Doe, John"]
[Black "Smith, Bob"]
[Result "1-0"]
1.Nf3 1-0
END_OF_PGN
    
    assert_equal expected, @writer.write(info, @history)
  end
  
  private
  
  def add_move(*args)
    move = unpack_move(*args)
    validate = @game.validator.new(@history.state)
    assert validate[move]
    state = @history.state.dup
    state.perform! move
    @history.add_move(state, move)
  end
end
