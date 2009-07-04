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
require 'premover'

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
    @premover = Premover.new(self, @board, @pools)
    
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
    @match.move(@controlled[turn], move, opts)
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
      @premover.execute
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
  
  def execute_move(src, dst, opts = { })
    state = @match.history.state
    move = @policy.new_move(state, src, dst)
    validate = @match.game.validator.new(state)
    if validate[move]
      perform!(move, opts)
      move
    end
  end

  def execute_drop(item, dst)
    state = @match.history.state
    move = @policy.new_move(state, nil, dst,
                            :dropped => item.name)
    validate = @match.game.validator.new(state)
    if validate[move]
      perform! move, :adjust => true, :dropped => item
      move
    end
  end
  
  def execute_direct_drop(color, index, dst)
    state = @match.history.state
    item = @pools[color].items[index]
    if item
      move = @policy.new_move(state, nil, dst,
                              :dropped => item.name)
      validate = @match.game.validator.new(state)
      if validate[move]
        perform! move
        move
      end
    end
  end
  
  def on_board_click(p)
    state = @match.history.state
    # if there is a selection already, move or premove
    # to the clicked square
    if @board.selection
      case @policy.movable?(@match.history.state, @board.selection)
      when :movable
        # move directly
        execute_move(@board.selection, p)
      when :premovable
        # schedule a premove on the board
        @premover.move(@board.selection, p)
      end
      @board.selection = nil
    elsif movable?(state, p)
      # only set selection
      @board.selection = p
    end
  end
  
  def on_board_drop(data)
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
        case @policy.movable?(@match.history.state, data[:src])
        when :movable
          move = execute_move(data[:src], data[:dst], :adjust => true)
        when :premovable
          @premover.move(data[:src], data[:dst])
        end
      end
    elsif data[:index] and data[:dst]
      # actual drop
      case droppable?(@match.history.state, 
                      data[:pool_color], 
                      data[:index])
      when :droppable
        move = execute_drop(data[:item], data[:dst])
      when :predroppable
        @premover.drop(data[:pool_color], data[:index], data[:dst])
      end
    end
    
    cancel_drop(data) unless move
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
    if droppable?(@match.history.state, c, data[:index])
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
  
  def droppable?(state, color, index)
    result = @policy.droppable?(state, color, index)
    return false unless result
    return false unless result == :droppable || @premove
    return false unless @controlled[color]
    return false if @match.history.current < @match.index and (not @match.editable?)
    result
  end
end
