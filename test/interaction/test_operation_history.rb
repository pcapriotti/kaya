# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'interaction/operation_history'

class TestOperationHistory < Test::Unit::TestCase
  def setup
    @operations = OperationHistory.new
  end
  
  def test_initial_state
    assert_equal 0, @operations.size
    assert_equal -1, @operations.current
  end
  
  def test_add_operation
    @operations << 'op'
    assert_equal 1, @operations.size
    assert_equal 0, @operations.current
  end
  
  def test_add_then_undo
    @operations << 'op'
    assert_equal 'op', @operations.undo_operation
    assert_equal 1, @operations.size
    assert_equal -1, @operations.current
  end
  
  def test_undo_at_beginning
    @operations << 'op'
    assert_equal 'op', @operations.undo_operation
    assert_nil @operations.undo_operation
  end
  
  def test_add_undo_redo
    @operations << 'op'
    assert_equal 'op', @operations.undo_operation
    assert_equal 'op', @operations.redo_operation
    assert_equal 1, @operations.size
    assert_equal 0, @operations.current
  end
  
  def test_navigate
    (1..10).each do |i|
      @operations << "op#{i}"
    end
    assert_equal 10, @operations.size
    assert_equal 9, @operations.current
    
    3.times { @operations.undo_operation }
    
    assert_equal 6, @operations.current
    
    assert_equal "op8", @operations.redo_operation
    assert_equal "op9", @operations.redo_operation
    
    @operations.undo_operation
    
    assert_equal "op9", @operations.redo_operation
    assert_equal "op10", @operations.redo_operation
    
    assert_equal 9, @operations.current
  end
  
  def test_redo_after_move
    @operations << "move"
    assert_equal 1, @operations.size
    assert_equal 0, @operations.current
    @operations.undo_operation
    assert_equal 1, @operations.size
    assert_equal -1, @operations.current
    @operations << "move"
    assert_equal 1, @operations.size
    assert_equal 0, @operations.current
  end
end
