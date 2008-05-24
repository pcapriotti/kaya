require 'test/unit'
require 'history'

class TestHistory < Test::Unit::TestCase
  def setup
    @history = History.new("initial_state")
  end
  
  def test_initial_state
    assert_equal 0, @history.current
    assert_equal "initial_state", @history.state
    assert_nil @history.move
    assert_equal 1, @history.size
  end
  
  def test_add_move
    @history.add_move("new_state", "first_move")
    assert_equal 1, @history.current
    assert_equal "new_state", @history.state
    assert_equal "first_move", @history.move
    assert_equal 2, @history.size
    @history.add_move("new_new_state", "second_move")
    assert_equal 2, @history.current
    assert_equal "new_new_state", @history.state
    assert_equal "second_move", @history.move
    assert_equal 3, @history.size
  end
  
  def test_back_on_first
    assert_raise History::OutOfBound do
      @history.back
      assert_equal 0, @history.current
    end
  end
  
  def test_forward_on_last
    @history.add_move("new_state", "first_move")
    assert_raise History::OutOfBound do
      @history.forward
      assert_equal 1, @history.current
    end
  end
  
  def test_back
    @history.add_move("new_state", "first_move")
    @history.back
    assert_equal 0, @history.current
  end
  
  def test_forward
    @history.add_move("new_state", "first_move")
    @history.back
    @history.forward
    assert_equal 1, @history.current
  end
  
  def test_overwrite_moves
    @history.add_move("new_state1", "first_move1")
    @history.add_move("new_new_state1", "second_move1")
    @history.back
    @history.back
    @history.add_move("new_state2", "first_move2")
    assert_equal 1, @history.current
    assert_equal "new_state2", @history.state
    assert_equal "first_move2", @history.move
    assert_equal 2, @history.size
  end
end
