# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require 'interaction/history'
require 'board/pool_animator'
require 'clock'
require 'interaction/match'
require 'premover'
require 'executor'

class Controller
  include Observer
  include Observable
  include Player
  include Executor
  
  attr_reader :match, :policy
  attr_reader :color
  attr_reader :controlled
  attr_reader :table
  attr_reader :policy
  attr_accessor :name
  attr_accessor :premove
  
  def initialize(table, field)
    @table = table
    @scene = @table.scene

    @pools = { }
    @clocks = { }
    @field = field
    @controlled = { }
  end
  
  def each_element
    yield @board if @board
    @pools.each {|c, pool| yield pool }
    @clocks.each {|c, clock| yield clock }
  end
  
  def reset(match)
    @match = match
    @policy = match.game.policy.new
    @current = match.history.current
    
    @table.reset(match)
    @board = @table.elements[:board]
    @pools = @table.elements[:pools]
    @clocks = @table.elements[:clocks]
    @premover = Premover.new(self, @board, @pools)
    
    @animator = match.game.animator.new(@board)
    @board.reset(match.state.board)
    update_pools
    
    @clocks.each do |col, clock|
      clock.stop
    end
    
    @board.observe(:click) {|p| on_board_click(p) }
    @board.observe(:drag) {|data| on_board_drag(data) }
    @board.observe(:drop) {|data| on_board_drop(data) }
    @pools.each do |col, pool|
      pool.observe(:drag) {|data| on_pool_drag(col, data) }
      pool.observe(:drop) {|data| on_pool_drop(col, data) }
    end
    @clocks.each do |col, clock|
      clock.data = { :color => col,
                     :player => match.player(col).name }
    end
    
    match.history.observe(:current_changed) { refresh }
    match.history.observe(:truncate) { refresh :instant => true }
    match.history.observe(:force_update) { refresh :force => true }
    match.history.observe(:new_move) do |data|
      refresh(data[:opts])
      if match.time_running?
        @clocks.each do |player, clock|
          if data[:state].turn == player
            clock.start
          else
            clock.stop
          end
        end
      end
    end
    
    @clocks[match.game.players.first].active = true
    @table.flip(@color && (@color != match.game.players.first))
    
    if match.history.move
      @board.highlight(match.history.move)
    end
    fire_active_actions(@current)
  end
  
  def back
    navigate :back
  end
  
  def forward
    navigate :forward
  end
  
  def undo!
    return unless match
    match.undo!(self)
  end
  
  def redo!
    return unless match
    return unless match.editable?
    match.redo!(self)
  end
  
  # sync displayed state with current history item
  # opts[:force] => update even if index == @current
  # opts[:instant] => update without animating
  # 
  def refresh(opts = { })
    return unless match
    index = match.history.current
    fire_active_actions(index)
    return if index == @current && (!opts[:force])
    if opts[:instant] || (index == @current && opts[:force])
      anim = @animator.warp(match.history.state, opts)
      perform_animation anim
    elsif index > @current
      (@current + 1..index).each do |i|
        animate(:forward, match.history[i].state, match.history[i].move, opts)
      end
    elsif index < @current
      @current.downto(index + 1).each do |i|
        animate(:back, match.history[i - 1].state, match.history[i].move, opts)
      end
    end
    @current = index
    @board.highlight(match.history[@current].move)
    if @premover.index and @current == @premover.index + 1
      @premover.execute
    else
      @premover.cancel
    end
  end
  
  def fire_active_actions(index)
    fire :active_actions => {
      :forward => match.navigable? || index < match.history.size - 1,
      :back => index > 0,
      :undo => @color && match.history.operations.current >= 0,
      :redo => @color && match.editable? && match.history.operations.current < match.history.operations.size - 1,
    }
  end
  
  def go_to(index)
    return unless match
    match.history.go_to(index)
  rescue History::OutOfBound
    puts "error: no such index #{index}"
  end
  
  def animate(direction, state, move, opts = {})
    anim = @animator.send(direction, state, move, opts)
    perform_animation anim
  end
  
  def perform_animation(anim)
    @field.run anim
    update_pools
  end
  
  def on_board_click(p)
    return unless match
    state = match.history.state
    # if there is a selection already, move or premove
    # to the clicked square
    if @board.selection
      case policy.movable?(match.history.state, @board.selection)
      when :movable
        # move directly
        execute_move(@board.selection, p)
      when :premovable
        # schedule a premove on the board
        @premover.move(@current, @board.selection, p)
      end
      @board.selection = nil
    elsif movable?(state, p)
      # only set selection
      @board.selection = p
    end
  end
  
  def on_board_drop(data)
    return unless match
    move = nil
    @board.add_to_group data[:item]
    @board.lower data[:item]
    
    if data[:src]
      # board to board drop
      if data[:src] == data[:dst]
        # null drop, handle as a click
        @board.selection = data[:src]
      elsif data[:dst]
        # normal move/premove
        case policy.movable?(match.history.state, data[:src])
        when :movable
          move = execute_move(data[:src], data[:dst], :adjust => true)
        when :premovable
          @premover.move(@current, data[:src], data[:dst])
        end
      end
    elsif data[:index] and data[:dst]
      # actual drop
      case droppable?(match.history.state, 
                      data[:pool_color], 
                      data[:index])
      when :droppable
        move = execute_drop(data[:item], data[:dst])
      when :predroppable
        @premover.drop(@current, data[:pool_color], data[:index], data[:dst])
      end
    end
    
    cancel_drop(data) unless move
  end
  
  def on_board_drag(data)
    return unless match
    if movable?(match.history.state, data[:src])
      @board.raise data[:item]
      @board.remove_from_group data[:item]
      data[:item].parent_item = nil
      @board.selection = nil
      @scene.on_drag(data)
    end
  end
  
  def on_pool_drag(c, data)
    return unless match
    if droppable?(match.history.state, c, data[:index])
      # replace item with a correctly sized one
      item = @board.create_piece(data[:item].name)
      @board.raise item
      @board.remove_from_group item
      item.parent_item = nil
      anim = @pools[c].animator.remove_piece(data[:index])
      data[:item] = item
      data[:size] = @board.unit
      data[:pool_color] = c
      
      @scene.on_drag(data)
      
      @field.run anim
    end
  end
  
  def on_pool_drop(color, data)
    cancel_drop(data)
  end
    
  def on_time(time)
    time.each do |pl, seconds|
      @clocks[pl].clock ||= Clock.new(seconds, 0, nil)
      @clocks[pl].clock.set_time(seconds)
    end
  end
  
  def on_close(data)
    @clocks.each do |pl, clock|
      clock.stop
    end
    @controlled = { }
  end
  
  def add_controlled_player(player)
    @controlled[player.color] = player
  end
  
  def color=(value)
    @match.close if @match
    @match = nil
    
    @color = value
    if @color
      @controlled = { @color => self }
    else
      @controlled = { }
    end
  end
    
  def allow_undo?
    if match && match.editable?
      manager.undo(1, :allow_more => true)
    else
      manager.undo(nil)
    end
  end
    
  private
  
  def navigate(direction)
    return unless match
    match.navigate(self, direction)
  rescue History::OutOfBound
    puts "error: out of bound"
  end
  
  def movable?(state, p)
    result = policy.movable?(state, p)
    return false unless result
    return false unless result == :movable || @premove
    return false unless @controlled[state.board[p].color]
    return false if match.history.current < match.index and (not match.editable?)
    result
  end
  
  def droppable?(state, color, index)
    result = policy.droppable?(state, color, index)
    return false unless result
    return false unless result == :droppable || @premove
    return false unless @controlled[color]
    return false if match.history.current < match.index and (not match.editable?)
    result
  end
  
  def perform!(move, opts = {})
    turn = match.history.state.turn
    match.move(self, move, opts)
  end
  
  def cancel_drop(data)
    anim = if data[:index]
      # remove dragged item
      data[:item].remove
      # make original item reappear in its place
      @pools[data[:pool_color]].animator.insert_piece(
        data[:index],
        data[:item].name)
    elsif data[:src]
      @animator.movement(data[:item], nil, data[:src], Path::Linear)
    end
    
    @field.run(anim) if anim
  end
  
  def update_pools
    @pools.each do |col, pool|
      anim = pool.animator.warp(match.history.state.pool(col))
      @field.run anim
    end
  end
end
