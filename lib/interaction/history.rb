# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils.rb'
require 'interaction/operation'
require 'interaction/operation_history'

class History
  include Enumerable
  include Observable
  include OperationInterface
  
  attr_reader :current
  attr_reader :operations
  
  Item = Struct.new(:state, :move)
  OutOfBound = Class.new(Exception)

  def initialize(state)
    @history = [Item.new(state.dup, nil)]
    @current = 0
    @operations = OperationHistory.new
  end
  
  def each
    @history.each {|item| yield item.state, item.move }
  end
  
  def add_move(state, move, opts = { })
    op = operation do |op|
      op.truncate(@current + 1)
      op.move(Item.new(state.dup, move))
    end
    op.execute :extra => opts
  end
  
  def forward
    raise OutOfBound if @current >= @history.size - 1
    @current += 1
    item = @history[@current]
    
    fire :current_changed
    [item.state, item.move]
  end
  
  def back
    raise OutOfBound if @current <= 0
    move = @history[@current].move
    @current -= 1
    
    fire :current_changed
    [@history[@current].state, move]
  end
  
  def go_to(index)
    if index != @current
      item = self[index]
      @current = index
      fire :current_changed
      [item.state, item.move]
    end
  end
  
  def go_to_last
    go_to(size - 1)
  end
  
  def go_to_first
    go_to(0)
  end
  
  def state
    @history[current].state
  end
  
  def state=(value)
    @history[current].state = value
    fire :force_update
  end
  
  def set_item(state, move)
    @history[current] = Item.new(state, move)
    fire :force_update
  end
  
  def move
    @history[current].move
  end
  
  def undo!
    op = @operations.undo_operation
    if op
      op.undo
    end
  end
  
  def redo!
    op = @operations.redo_operation
    if op
      op.execute
    end
  end
  
  def size
    @history.size
  end
  
  def [](index)
    if index >= @history.size || index < 0
      raise OutOfBound 
    end
    @history[index]
  end
  
  # item interface
  
  def add_items(opts, *items)
    @history += items
    old_current = @current
    old_state = state
    @current = @history.size - 1  if opts.fetch(:go_to_end, true)
    fire :new_move => {
      :old_current => old_current,
      :old_state => old_state,
      :state => state,
      :opts => opts }
    @current
  end
  
  def remove_items_at(index)
    @current = index.pred
    fire :current_changed
    
    items = @history[index..-1]
    @history = @history[0...index]
    @current = if @current >= index
      index.pred
    else
      @current
    end
    fire :truncate => @current
    items
  end
  
  def current=(value)
    @current = value
  end
end
