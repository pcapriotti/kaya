# Copyright (c) 2010 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'require_bundle'
require 'test/unit'
require 'rubygems'
require 'mocha'
require_bundle 'ics', 'icsapi'
require 'games/all'

class TestIcsApi < Test::Unit::TestCase
  def setup
    @api = ICS::ICSApi.new(Game.get(:chess))
  end
  
  def test_parse_last_move
     move = @api.parse_last_move("P/d2-d3", :white)
     assert_equal Point.new(3, 6), move.src
     assert_equal Point.new(3, 5), move.dst
  end

  def test_parse_last_move_castling_k
    move = @api.parse_last_move("o-o", :black)
    assert_equal Point.new(4, 0), move.src
    assert_equal Point.new(6, 0), move.dst
    
    move = @api.parse_last_move("o-o", :white)
    assert_equal Point.new(4, 7), move.src
    assert_equal Point.new(6, 7), move.dst    
  end
  
  def test_parse_last_move_castling_q
    move = @api.parse_last_move("o-o-o", :black)
    assert_equal Point.new(4, 0), move.src
    assert_equal Point.new(2, 0), move.dst
    
    move = @api.parse_last_move("o-o-o", :white)
    assert_equal Point.new(4, 7), move.src
    assert_equal Point.new(2, 7), move.dst    
  end
end
