require 'interaction/match'

# This class represents a local player
# 
class User
  include Player
  
  attr_accessor :color
  
  def initialize(color, board, notify)
    @color = color
    @board = board
    @notify = notify
  end
  
  def reset(match)
    @board.flip!(color != :white)
    @board.warp(match.state)
    
    user = self
    @board.observe :new_move do |data|
      match.move(user, data[:move], data[:state])
    end
    
    @notify[:newGame => 'Starting new game']
  end
  
  def on_move(data)
    @board.forward(data[:state], data[:move])
    @notify[:move => "A new move has been played"]
  end
end
