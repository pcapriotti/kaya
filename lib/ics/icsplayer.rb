require 'interaction/match'

module ICS

class ICSPlayer
  include Player
  include Observer
  
  attr_reader :color, :name
  
  # create a new ICS player playing with
  # the given color and using the given
  # output channel to send moves
  def initialize(out, color, serializer, name)
    @color = color
    @out = out
    @serializer = serializer
    @name = name
  end

  def on_move(data)
    text = @serializer.serialize(data[:move], data[:old_state])
    @out[text]
  end
end

end