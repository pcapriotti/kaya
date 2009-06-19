require 'observer_utils'
require 'history'

class Controller
  include Observer
  
  attr_reader :history
  
  def initialize(board, history)
    @board = board
    @history = history
    
    board.add_observer self
  end
  
  def on_new_move(data)
    @history.add_move(data[:state], data[:move])
    @board.highlight(data[:move])
  end
  
  def on_back
    state, move = @history.back
    @board.back(state.dup, move)
    @board.highlight(@history.move)
  rescue History::OutOfBound
    puts "error: first move"
  end
  
  def on_forward
    state, move = @history.forward
    @board.forward(state.dup, move)
    @board.highlight(move)
  rescue History::OutOfBound
    puts "error: last move"
  end
end
