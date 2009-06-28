require 'observer_utils.rb'

class History
  include Enumerable
  include Observable
  
  attr_reader :current
  
  Item = Struct.new(:state, :move, :text)
  OutOfBound = Class.new(Exception)

  def initialize(state)
    @history = [Item.new(state.dup, nil, "Mainline")]
    @current = 0
  end
  
  def each
    @history.each {|item| yield item.state, item.move }
  end
  
  def add_move(state, move)
    item = Item.new(state.dup, move, nil)
    old_size = @history.size
    
    @history = @history[0..@current]

    @history << item
    @current = @history.size - 1
    
    fire :new_move
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
    item = self[index]
    @current = index
    fire :current_changed
    [item.state, item.move]
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
end
