# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require_bundle 'chess', 'move'

module Shogi
  class Move < Chess::Move
    attr_reader :dropped
    
    def initialize(src, dst, opts = {})
      super
      @dropped = opts[:dropped]
      @promote = opts[:promote]
    end
    
    def self.drop(piece, dst)
      new(nil, dst, :dropped => piece)
    end
    
    def promote?
      @promote
    end
  end
end
