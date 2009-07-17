# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'

require 'controller'
require 'helpers/stubs.rb'
require "games/all"
require 'dummy_player'
require 'board/scene'
require 'qtutils'
require 'board/element_manager'

class TestController < Test::Unit::TestCase
  class FakeTable
    include ElementManager
    attr_reader :scene, :elements, :game, :theme
    
    def initialize(game)
      @game = game
      @scene = Scene.new
      @loader = PluginLoader.new
    end
    
    def reset(match)
      @theme = @loader.get_matching(:theme_loader).new.load(@game)
      @elements = create_elements
    end
    
    def flip(value)
    end
  end
  
  def setup
    $qApp or Qt::Application.new([])
    field = GeneralMock.new
    @game = Game.get(:shogi)
    @table = FakeTable.new(@game)
    @controller = Controller.new(@table, field)
  end
  
	def test_initial_state
		assert_nil @controller.match
  end
  
  def test_single_player
    match = Match.new(@game)
    setup_single_player(match)
    @controller.reset(match)
    assert_equal match, @controller.match
  end
  
  private
  
  def setup_single_player(match)
    @controller.color = :white
    @controller.premove = false
    opponent = DummyPlayer.new(:black)
    @controller.add_controlled_player(opponent) 
    match.register(@controller)
    match.register(opponent)
    match.start(@controller)
    match.start(opponent)
    assert match.started?
  end
end