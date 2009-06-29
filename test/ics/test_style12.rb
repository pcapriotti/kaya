# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'ics/style12'
require 'ics/icsapi'
require 'games/all'

class TestStyle12 < Test::Unit::TestCase
  def setup
    @chess = Game.get(:chess)
    @games = {
      257 => { :game => @chess,
               :icsapi => ICS::ICSApi.new(@chess) } }
  end
  
  def test_initial_position
    line = '<12> rnbqkbnr pppppppp -------- -------- -------- -------- ' +
      'PPPPPPPP RNBQKBNR W -1 1 1 1 1 0 257 hello world 1 2 12 39 39 ' +
      '120000 120000 1 none (0:00.000) none 0 0 0'
    m = ICS::Style12::PATTERN.match(line)
    assert_not_nil m
    s12 = ICS::Style12.from_match(m, @games)
    assert_equal @chess.state.new.tap{|b| b.setup }, s12.state
  end
end
      
        

