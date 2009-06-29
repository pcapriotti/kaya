# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'ics/protocol'

class TestProtocol < Test::Unit::TestCase
  def setup
    @protocol = ICS::Protocol.new(false)
  end

  def test_create_game
    example1 = "Creating: azsxdc (++++) Hispanico (1684) unrated crazyhouse 3 0"
    example2 = "{Game 502 (azsxdc vs. Hispanico) Creating unrated crazyhouse match.}"
    
    game_info = nil
    @protocol.observe(:creating_game) { |game_info| }
    @protocol.process(example1)
    @protocol.process(example2)
    
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
  
  def test_beep
    fired = false
    @protocol.observe :beep do
      fired = true
    end
    @protocol.process("\a")
    assert fired
  end
end
