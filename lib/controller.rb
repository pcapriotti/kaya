# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require 'history'
require 'board/pool_animator'
require 'clock'
require 'interaction/match'

class Controller
  include Observer
  include Player
  
  attr_reader :match
  attr_reader :color
  attr_reader :controlled
  attr_reader :table
  attr_reader :policy
  attr_accessor :name
  attr_accessor :premove
  
  def initialize(table)
    @table = table
    @scene = @table.scene

    @pools = { }
    @clocks = { }
    
    @field = AnimationField.new(20)
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
    
    @table.reset(@match)
    @board = @table.elements[:board]
    @pools = @table.elements[:pools]
    @clocks = @table.elements[:clocks]
    
    @animator = @match.game.animator.new(@board)
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
    
    @match.history.observe(:current_changed) { refresh }
    
    @match.observe(:move) do |data|
      refresh(data[:opts])
      @clocks[data[:old_state].turn].stop
      @clocks[data[:state].turn].start
    end
    
    @clocks[@match.game.players.first].active = true
    @table.flip(@color && (@color != @match.game.players.first))
    
    if @match.history.move
      @board.highlight(@match.history.move)
    end
  end
  
  def perform!(move, opts = {})
    turn = @match.history.state.turn
    if @controlled[turn]
      @next_refresh_opts = opts
      @match.move(@controlled[turn], move, opts)
    end
  end
  
  def back
    @match.history.back
  rescue History::OutOfBound
    puts "error: first move"
  end
  
  def forward
    @match.history.forward
  rescue History::OutOfBound
    puts "error: last move"
  end
  
  # sync displayed state with current history item
  # 
  def refresh(opts = { })
    if @match
      index = @match.history.current
      if index > @current
        (@current + 1..index).each do |i|
          animate(:forward, @match.history[i].state, @match.history[i].move, opts)
        end
      elsif index < @current
        @current.downto(index + 1).each do |i|
          animate(:back, @match.history[i - 1].state, @match.history[i].move, opts)
        end
      end
      @current = index
      @board.highlight(@match.history[@current].move)
      if @board.premove_src and @board.premove_dst
        execute_move(@board.premove_src, @board.premove_dst)
      end
      @board.cancel_premove
    end
  end
  
  def go_to(index)
    @match.history.go_to(index)
  rescue History::OutOfBound
    puts "error: no such index #{index}"
  end
  
  def animate(direction, state, move, opts = {})
    anim = @animator.send(direction, state, move, opts)
    @field.run anim
    
    update_pools
  end
  
  def update_pools
    @pools.each do |col, pool|
      anim = pool.animator.warp(@match.history.state.pool(col))
      @field.run anim
    end
  end
  
  def execute_move(src, dst)
    state = @match.history.state
    move = @policy.new_move(state, src, dst)
    validate = @match.game.validator.new(state)
    if validate[move]
      perform! move
    end    
  end
  
  def on_board_click(p)
    state = @match.history.state
    if @board.selection
      case @policy.movable?(@match.history.state, @board.selection)
      when :movable
        execute_move(@board.selection, p)
      else
        if p == @board.selection
          @board.cancel_premove
        else
          @board.premove(@board.selection, p) 
        end
      end
      @board.selection = nil
    elsif movable?(state, p)
      @board.selection = p
    end
  end
  
  def on_board_drop(data)
    if data[:src]
      move = nil
      
      if data[:src] == data[:dst]
        @board.selection = data[:src]
      elsif data[:dst]
        # normal move/premove
        case @policy.movable?(@match.history.state, data[:src])
        when :movable
          move = @policy.new_move(
            @match.history.state, data[:src], data[:dst])
          validate = @match.game.validator.new(@match.history.state)
          validate[move]
        when :premovable
          @board.premove(data[:src], data[:dst])
        end
      end
      
      if move and move.valid?
        @board.add_to_group data[:item]
        @board.lower data[:item]
        perform! move, :adjust => true
      else
        cancel_drop(data)
      end
    elsif data[:index] and data[:dst]
      # actual drop
      move = @policy.new_move(
        @match.history.state, nil, data[:dst], 
        :dropped => data[:item].name)
      validate = @match.game.validator.new(@match.history.state)
      if validate[move]
        @board.add_to_group data[:item]
        @board.lower data[:item]
        perform! move, :adjust => true, :dropped => data[:item]
      else
        cancel_drop(data)
      end
    end
  end
  
  def on_board_drag(data)
    if movable?(@match.history.state, data[:src])
      @board.raise data[:item]
      @board.remove_from_group data[:item]
      @board.selection = nil
      @scene.on_drag(data)
    end
  end
  
  def on_pool_drag(c, data)
    if @policy.droppable?(@match.history.state, c, data[:index]) and 
       droppable?(c, data[:index])
       
       
      # replace item with a correctly sized one
      item = @board.create_piece(data[:item].name)
      @board.raise item
      @board.remove_from_group item
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
  
  def cancel_drop(data)
    anim = if data[:index]
      # remove dragged item
      data[:item].remove
      # make original item reappear in its place
      @pools[data[:pool_color]].animator.insert_piece(
        data[:index],
        data[:item].name)
    elsif data[:src]
      @board.add_to_group data[:item]
      @board.lower data[:item]
      @animator.movement(data[:item], nil, data[:src], Path::Linear)
    end
    
    @field.run(anim) if anim
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
    end
  end
    
  def movable?(state, p)
    result = @policy.movable?(state, p)
    return false unless result
    return false unless result == :movable || @premove
    return false unless @controlled[state.board[p].color]
    return false if @match.history.current < @match.index and (not @match.editable?)
    result
  end
  
  def droppable?(color, index)
    return false unless @controlled[@match.history.state.turn]
    if @match.history.current < @match.index
      @match.editable?
    else
      true
    end
  end
end
