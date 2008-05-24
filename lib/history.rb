require 'observer_utils.rb'

class History
  include Enumerable
  include Observer
  
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
    item = Item.new(state.dup, move)
    @history = @history[0..@current]
    @history << item
    @current = @history.size - 1
  end
  
  def forward
    raise OutOfBound if @current >= @history.size - 1
    @current += 1
    item = @history[@current]
    [item.state, item.move]
  end
  
  def back
    raise OutOfBound if @current <= 0
    move = @history[@current].move
    @current -= 1
    [@history[@current].state, move]
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
end
