# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Chess
  class Piece
    attr_reader :color, :type
    SYMBOLS = { :knight => 'N' }
    TYPES = { 'P' => :pawn,
              'R' => :rook,
              'B' => :bishop,
              'N' => :knight,
              'Q' => :queen,
              'K' => :king }
  
    def initialize(color, type)
      @color = color
      @type = type
    end
    
    def ==(other)
      @color == other.color and @type == other.type
    end
    
    def name
      "#@color #@type"
    end
    
    def symbol
      s = self.class.symbol(type)
      s = s.downcase if color == :black
      s
    end
    
    def same_color_of?(other)
      other and other.color == color
    end
    
    def to_s
      name
    end
    
    def eql?(other)
      other.instance_of?(self.class) and self == other
    end
    
    def hash
      [@color, @type].hash
    end
    
    def self.symbol(type)
      SYMBOLS[type] || type.to_s[0, 1].upcase
    end
    
    def self.type_from_symbol(sym)
      TYPES[sym.upcase]
    end
  end
end
