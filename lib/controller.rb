require 'observer_utils'
require 'history'

class Controller
  include Observer
  
  def initialize(board)
    @board = board
    @history = History.new(board.state)
    
    board.add_observer self
  end
  
  def on_new_move(data)
    @history.add_move(data[:state], data[:move])
  end
  
  def on_back
    state, move = @history.back
    @board.back(state.dup, move)
  rescue History::OutOfBound
    puts "error: first move"
  end
  
  def on_forward
    state, move = @history.forward
    @board.forward(state.dup, move)
  rescue History::OutOfBound
    puts "error: last move"
  end
end
