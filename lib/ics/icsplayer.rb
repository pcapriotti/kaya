require 'interaction/match'

module ICS

class ICSPlayer
  include Player
  
  attr_reader :color
  
  # create a new ICS player playing with
  # the given color and using the given
  # output channel to send moves
  def initialize(out, color)
    @color = color
    @out = out
  end

  def on_move(data)
    move = data[:move]
    out[move.to_san]    
  end
end

end