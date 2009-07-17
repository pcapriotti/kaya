# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require "test/unit"

require "interaction/undo_manager"

class TestUndoManager < Test::Unit::TestCase
  def setup
    @manager = UndoManager.new
    @manager.metaclass_eval do
      public :find_common
    end
  end
  
	def test_find_common
		@manager.undo(:a, 2)
    @manager.undo(:b, 3)
    assert_nil @manager.find_common
	end
  
  def test_find_common2
    @manager.undo(:a, 2, :allow_more => true)
    @manager.undo(:b, 3)
    assert_equal 3, @manager.find_common
  end
  
  def test_find_common3
    @manager.undo(:a, 3, :allow_more => true)
    @manager.undo(:b, nil)
    assert_equal nil, @manager.find_common
  end
  
  def test_find_common4
    @manager.undo(:a, 1, :allow_more => true)
    @manager.undo(:b, 2)
    @manager.undo(:c, 3)
    assert_equal nil, @manager.find_common
  end
  
  def test_find_common5
    @manager.undo(:a, 3)
    @manager.undo(:b, 1, :allow_more => true)
    assert_equal 3, @manager.find_common
  end
end