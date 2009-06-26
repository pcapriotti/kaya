require 'games/chess/policy'

module Shogi

class Policy < Chess::Policy
  attr_accessor :autopromote
  
  def initialize(move_factory, validator_factory, autopromote)
    @move_factory = move_factory
    @validator_factory = validator_factory
    @autopromote = autopromote
  end
  
  def new_move(state, src, dst, opts = {})
    promote = @autopromote
    move = @move_factory.new(src, dst, opts.merge(:promote => promote))
    valid = @validator_factory.new(state)
    move = @move_factory.new(src, dst, opts.merge(:promote => !promote)) unless valid[move]
    move
  end
end

end