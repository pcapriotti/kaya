# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils.rb'
require 'interaction/operation'

class History
  include Enumerable
  include Observable
  include OperationInterface
  
  attr_reader :current
  
  Item = Struct.new(:state, :move)
  OutOfBound = Class.new(Exception)

  def initialize(state)
    @history = [Item.new(state.dup, nil)]
    @current = 0
  end
  
  def each
    @history.each {|item| yield item.state, item.move }
  end
  
  def add_move(state, move)
    operation(:execute => true) do |op|
      op.truncate(@current + 1)
      op.move(Item.new(state.dup, move))
    end
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
  
  def move
    @history[current].move
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
  
  def add_items(*items)
    @history += items
    @history.size - 1
  end
  
  def remove_items_at(index)
    items = @history[index..-1]
    @history = @history[0...index]
    items
  end
  
  def current=(value)
    @current = value
  end
end
