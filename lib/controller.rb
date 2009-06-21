require 'observer_utils'
require 'history'

class Controller
  include Observer
  
  attr_reader :history
  
  def initialize(board, game, history)
    @board = board
    @game = game
    @history = history
    @animator = @game.animator.new(board)
    @field = AnimationField.new(20)
    @board.reset(history.state.board)
    
    c = self
    board.observe(:click) {|p| c.on_board_click(p) }
  end
  
  def on_board_click(p)
    state = @history.state
    if @board.selection
      move = @game.policy.new_move(state, @board.selection, p)
      validate = @game.validator.new(state)
      if validate[move]
        perform! move
      end
      
      @board.selection = nil
    elsif @game.policy.movable?(state, p) and movable?(p)
      @board.selection = p
    end
  end
  
  def perform!(move)
    state = @history.state.dup
    state.perform! move
    @history.add_move(state, move)
    
    animate(:forward, state, move)
    @board.highlight(move)
  end
  
  def back
    state, move = @history.back
    animate(:back, state, move)
    @board.highlight(@history.move)
  rescue History::OutOfBound
    puts "error: first move"
  end
  
  def forward
    state, move = @history.forward
    animate(:forward, state, move)
    @board.highlight(move)
  rescue History::OutOfBound
    puts "error: last move"
  end
  
  def animate(direction, state, move)
    anim = @animator.send(direction, state, move)
    @field.run anim
  end
  
  def movable?(p)
    true
  end
end
