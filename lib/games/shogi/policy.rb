# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

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