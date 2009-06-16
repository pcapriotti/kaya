require 'interaction/match'

# This class represents a local player
# 
class User
  include Player
  
  attr_accessor :color
  
  def initialize(color, board)
    @color = color
    @board = board
  end
  
  def reset(match)
    puts "resetting to #{match.state.inspect}"
    puts "color = #{color}"
    @board.flip!(color != :white)
    @board.warp(match.state)
    
    user = self
    @board.observe :new_move do |data|
      match.move(user, data[:move], data[:state])
    end
  end
  
  def on_move(data)
    @board.forward(data[:state], data[:move])
  end
end
