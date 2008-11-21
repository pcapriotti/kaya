require 'test/unit'
require 'ics/protocol'

class TestProtocol < Test::Unit::TestCase
  def setup
    @protocol = ICS::Protocol.new
  end

  def test_create_game
    example = "Creating: azsxdc (++++) Hispanico (1684) unrated crazyhouse 3 0"
    game_info = nil
    @protocol.observe :create_game do |game_info|
    end
    @protocol.process(example)
    assert_not_nil game_info
    assert_equal 'azsxdc', game_info[:white][:name]
    assert_equal 0, game_info[:white][:score]
    assert_equal 'Hispanico', game_info[:black][:name]
    assert_equal 1684, game_info[:black][:score]
    assert_equal 'unrated', game_info[:rated]
    assert_equal 'crazyhouse', game_info[:type]
    assert_equal 3, game_info[:time]
    assert_equal 0, game_info[:increment]
  end

  def test_login
    fired = false
    @protocol.observe :login_prompt do
      fired = true
    end
    @protocol.process_partial("login: ")
    assert fired
  end

  def test_login
    fired = false
    @protocol.observe :login_prompt do
      fired = true
    end
    @protocol.process("login: ")
    assert !fired
  end
end
