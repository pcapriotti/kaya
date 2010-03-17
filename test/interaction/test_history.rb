# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'interaction/history'

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
  
  def test_operations
    @history.add_move("new_state1", "first_move1")
    @history.add_move("new_new_state1", "second_move1")
    assert_equal 2, @history.operations.size
  end
  
  def test_undo
    @history.add_move("new_state1", "first_move1")
    @history.add_move("new_new_state1", "second_move1")
    @history.undo!
    assert_equal 1, @history.current
    assert_equal "new_state1", @history.state
    assert_equal "first_move1", @history.move
  end
  
  def test_redo
    @history.add_move("new_state1", "first_move1")
    @history.add_move("new_new_state1", "second_move1")
    @history.undo!
    @history.redo!
    assert_equal 2, @history.current
    assert_equal "new_new_state1", @history.state
    assert_equal "second_move1", @history.move
  end
  
  def test_undo_overwrite
    @history.add_move("new_state1", "first_move1")
    @history.add_move("new_new_state1", "second_move1")
    @history.back
    @history.back
    @history.add_move("new_state2", "first_move2")
    @history.undo!
    assert_equal 0, @history.current
    assert_equal "initial_state", @history.state
    assert_nil @history.move
  end
end
