# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'games/games'
require 'helpers/validation_helper'

class TestShogiState < Test::Unit::TestCase
  include ValidationHelper

  def setup
    @game = Game.get(:shogi)
    @state = @game.state.new
    @board = @state.board
  end
  
  def test_initialize
    assert_equal @board, @state.board
    assert_equal :black, @state.turn
    assert @state.pool(:white).empty?
    assert @state.pool(:black).empty?
  end
  
  def test_setup
    @state.setup
    
    (0...9).each do |i|
      assert_piece :black, :pawn, i, 6
      assert_piece :white, :pawn, i, 2
    end
    
    assert_piece :black, :lance, 0, 8
    assert_piece :black, :horse, 1, 8
    assert_piece :black, :king, 4, 8
    assert_piece :white, :silver, 6, 0
    assert_piece :white, :gold, 3, 0
    assert_piece :black, :gold, 5, 8
    assert_piece :black, :bishop, 1, 7
    assert_piece :black, :rook, 7, 7
    assert_piece :white, :bishop, 7, 1
    assert_piece :white, :rook, 1, 1
    assert_no_piece 6, 4
    assert_no_piece 3, 5
  end
  
  def test_colors
    assert_equal [:black, :white], @state.to_enum(:each_color).to_a
  end
  
  def test_row
    assert_equal 3, @state.row(3, :white)
    assert_equal 5, @state.row(3, :black)
  end
  
  def test_opposite_color
    assert_equal :white, @state.opposite_color(:black)
    assert_equal :black, @state.opposite_color(:white)
  end
  
  def test_direction
    assert_equal Point.new(0, -1), @state.direction(:black)
    assert_equal Point.new(0, 1), @state.direction(:white)
  end
  
  def test_in_promotion_zone
    assert @state.in_promotion_zone?(Point.new(0, 0), :black)
    assert @state.in_promotion_zone?(Point.new(4, 2), :black)
    assert @state.in_promotion_zone?(Point.new(8, 1), :black)
    assert !@state.in_promotion_zone?(Point.new(6, 5), :black)
    assert !@state.in_promotion_zone?(Point.new(2, 8), :black)
    assert !@state.in_promotion_zone?(Point.new(6, 5), :white)
    assert @state.in_promotion_zone?(Point.new(4, 6), :white)
    assert @state.in_promotion_zone?(Point.new(7, 7), :white)
    assert @state.in_promotion_zone?(Point.new(1, 8), :white)
  end
end
