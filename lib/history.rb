require 'observer_utils.rb'

class History < Qt::AbstractListModel
  include Enumerable
  include Observer
  include ModelUtils
  
  attr_reader :current
  
  Item = Struct.new(:state, :move, :text)
  OutOfBound = Class.new(Exception)

  def initialize(state)
    super(nil)
    @history = [Item.new(state.dup, nil, "Mainline")]
    @current = 0
  end
  
  def each
    @history.each {|item| yield item.state, item.move }
  end
  
  def add_move(state, move)
    item = Item.new(state.dup, move, nil)
    
    removing_rows(nil, @current + 1, @history.size - 1) do
      @history = @history[0..@current]
    end

    inserting_rows(nil, @current + 1, @current + 1) do
      @history << item
      @current = @history.size - 1
    end
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
  
  def [](index)
    @history[index]
  end
  
  # model interface
  
  # set a serializer for this model
  # if no serializer has been set, it will
  # be impossible to use it with a view
  def serializer=(ser)
    @serializer = ser
  end
  
  def data(index, role)
    if @serializer and role == Qt::DisplayRole
      unless @history[index.row].text
        state = @history[index.row - 1].state
        move = @history[index.row].move
        san = @serializer.serialize(move, state)
        
        count = index.row / 2 + 1
        dots = if index.row % 2 == 0
          '.'
        else
          '...'
        end
        
        @history[index.row].text = "#{count}#{dots} #{san}"
      end
      @history[index.row].text
    end
  end
  
  def rowCount(parent)
    size
  end
  
end
