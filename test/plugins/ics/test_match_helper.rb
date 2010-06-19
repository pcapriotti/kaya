# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'require_bundle'
require_bundle 'ics', 'match_helper'
require 'interaction/history'
require 'rubygems'
require 'mocha'
require 'games/all'
require 'ostruct'

class TestMatchHelper < Test::Unit::TestCase
  def setup
    chess = Game.get(:chess)
    connection = stub_everything("connection")
    
    @protocol = stub_everything("protocol") do
      stubs(:connection).returns(connection)
    end
    @user = stub_everything("user")
    @match = stub_everything("match") do
      history = History.new(chess.state.new.tap{|s| s.setup })
      
      stubs(:game).returns(chess)
      stubs(:history).returns(history)
      stubs(:started?).returns(true)
    end
    
    @match_info = {
      :game => chess,
      :number => 37,
      :white => { :name => 'Karpov' },
      :black => { :name => 'Fisher' },
      :icsapi => stub_everything("icsapi"),
      :match => @match
    }
    @style12 = OpenStruct.new(
      :game_number => 37,
      :relation => ICS::Style12::Relation::MY_MOVE,
      :state => chess.state.new.tap {|s| s.setup },
      :move_index => 0)

  end
  
  def test_default_start
    helper = ICS::DefaultMatchHelper.new
    @user.expects(:name=).with("Karpov")
    @match.expects(:start).with(@user)
    @match.expects(:start).with{|opp| opp.name == "Fisher" }
    helper.start(@protocol, @user, @match_info, @style12)
  end
  
  def test_default_get_match
    helper = ICS::DefaultMatchHelper.new
    info = helper.get_match(@protocol, @match_info, @style12)
    assert_same @match, info[:match]
    
    info = helper.get_match(@protocol, nil, @style12)
    assert_nil info
  end
  
  def test_examination_start
    helper = ICS::ExaminingMatchHelper.new
    @match.expects(:start).with{|player| player.name == "Karpov" }
    @match.expects(:start).with{|player| player.name == "Fisher" }
    helper.start(@protocol, @user, @match_info, @style12)
  end
  
  def test_examination_get_match
    helper = ICS::ExaminingMatchHelper.new
    info = helper.get_match(@protocol, @match_info, @style12)
    assert_same @match, info[:match]
    
    @style12.match_info = @match_info
    info = helper.get_match(@protocol, nil, @style12)
    assert_not_nil info
    assert_not_nil info[:match]
    assert_equal 37, info[:number]
  end
end
