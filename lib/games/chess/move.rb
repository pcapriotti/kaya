# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/validable'
require 'point'

module Chess
  class Move
    include Validable
    attr_reader :src, :dst
    attr_accessor :type, :promotion
    
    def initialize(src, dst, opts = {})
      @src = src
      @dst = dst
      @promotion = opts[:promotion]
    end

    def delta
      dst - src
    end
    
    def range
      PointRange.new(src, dst)
    end
    
    def to_s
      "#{src} -> #{dst}"
    end
    
    def == other
      other and @src == other.src and 
      @dst == other.dst and @promotion == other.promotion and
      @type == other.type
    end
  end
end
