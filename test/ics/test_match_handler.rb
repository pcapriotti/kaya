require 'test/unit'
require 'rubygems'
require 'mocha'
require 'ics/match_handler'
require 'games/games'
require 'ostruct'

class TestMatchHandler < Test::Unit::TestCase
  def test_creation
    user = mock("user")
    protocol = mock("protocol") do |x|
      x.expects(:add_observer)
    end
    icsapi = mock("icsapi")
    
    handler = ICS::MatchHandler.new(user, protocol)
    handler.on_creating_game :game => Game.get(:chess),
                             :number => 37,
                             :icsapi => icsapi
    assert_equal 1, handler.matches.size
    match, m_icsapi = handler.matches[37]
    assert_equal icsapi, m_icsapi
  end
  
  def test_style12
    user = mock("user") do |x|
      x.expects(:reset)
      x.expects(:color=).with(:white)
      x.expects(:color).at_least_once.returns(:white)
    end
    protocol = mock("protocol") do |x|
      x.expects(:add_observer)
    end
    icsapi = mock("icsapi")
    
    handler = ICS::MatchHandler.new(user, protocol)
    handler.on_creating_game :game => Game.get(:chess),
                             :number => 37,
                             :icsapi => icsapi
    handler.on_style12 OpenStruct.new(
                         :game_number => 37,
                         :relation => ICS::Style12::Relation::MY_MOVE,
                         :state => Game.get(:chess).state.new.tap {|s| s.setup },
                         :move_index => 0)
                       
    assert_equal 1, handler.matches.size
    match, m_icsapi = handler.matches[37]
    assert match.started?    
  end
end