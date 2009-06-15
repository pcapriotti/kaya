require 'test/unit'
require 'interaction/match'
require 'games/chess/chess'
require 'games/games'

class TestMatch < Test::Unit::TestCase
  def setup
    @match = Match.new Game.get(:chess)
  end

  def test_register
    p1 = fake_player(:white)
    p2 = fake_player(:black)
    
    assert @match.register(p1)
    assert ! @match.complete?
    assert @match.register(p2)
    assert @match.complete?
  end
  
  def test_register_twice
    p1 = fake_player(:white)
    
    assert @match.register(p1)
    assert ! @match.complete?
    assert ! @match.register(p1)
  end

  def test_register_multiple_players
    p1 = fake_player(:white)
    p2 = fake_player(:black)
    p3 = fake_player(:white)
    
    assert @match.register(p1)
    assert @match.register(p2)
    assert @match.complete?
    assert !@match.register(p3)
  end
  
  def test_start
    p1 = fake_player(:white)
    p2 = fake_player(:black)
    
    assert @match.register(p1)
    assert @match.register(p2)
    
    assert @match.start(p2)
    assert @match.start(p1)
    
    assert @match.started?
  end
  
  def test_start_incomplete
    p1 = fake_player(:white)
    
    assert @match.register(p1)
    assert !@match.start(p1)
  end
  
  def test_move
    p1 = fake_player(:white)
    p2 = fake_player(:black)
    
    
  end
  
  private
  
  def fake_player(c)
    player = Object.new
    class << player
      include Observer
    end
    player.metaclass_eval do
      define_method(:color) { c }
    end
    player
  end
end
