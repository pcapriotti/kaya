# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'rubygems'
require "test/unit"
require "board/board"
require "board/scene"
require 'mocha'
require 'helpers/theme_stubs'
require 'games/all'

class TestBoard < Test::Unit::TestCase
  def setup
    $qApp or Qt::Application.new([])
    theme = ThemeStub.new
    @game = Game.get(:chess)
    @scene = Scene.new
    @board = Board.new(@scene, theme, @game)
  end
  
  def teardown
    @scene.dispose
  end
  
	def test_empty_board
		assert_equal 0, @board.items.size
  end

  def test_reset_empty_state
    @board.reset(@game.state.new.board)
    assert_equal [:background],
                 @board.items.keys
  end
  
  def test_reset_initial_state
    @board.reset(@game.state.new.tap{|s| s.setup}.board)
    @board.set_geometry(Qt::Rect.new(0, 0, 100, 100))
    # 32 pieces + 1 background
    assert_equal 33, @board.items.size
    p = Point.new(5, 1)
    assert_equal @board.to_real(p),
                 @board.items[p].pos
    assert_equal @game.piece.new(:black, :pawn),
                 @board.items[p].name
  end
  
  def test_square_tag
    @board.reset(@game.state.new.board)
    @board.set_geometry(Qt::Rect.new(0, 0, 100, 100))
    p = Point.new(3, 2)
    @board.selection = p
    assert_equal [:background, :selection],
                 @board.items.keys.sort_by{|x| x.to_s }
    assert_equal p, @board.selection
    assert_equal @board.to_real(p), @board.items[:selection].pos
    
    @board.selection = nil
    assert_equal [:background],
                 @board.items.keys
  end
  
  def test_square_tag2
    @board.reset(@game.state.new.board)
    @board.set_geometry(Qt::Rect.new(0, 0, 100, 100))
    
    p1 = Point.new(3, 2)
    p2 = Point.new(6, 3)
    @board.highlight(@game.move.new(p1, p2))
    
    assert_equal [:background, :last_move_dst, :last_move_src],
                 @board.items.keys.sort_by{|x| x.to_s}
    assert_equal p1, @board.last_move_src
    assert_equal p2, @board.last_move_dst
    assert_equal @board.to_real(p1), @board.items[:last_move_src].pos
    assert_equal @board.to_real(p2), @board.items[:last_move_dst].pos
    
    @board.highlight(nil)
    assert_equal [:background], @board.items.keys
  end
end
