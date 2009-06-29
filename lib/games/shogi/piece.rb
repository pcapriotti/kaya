# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/chess/piece'

module Shogi

class Piece < Chess::Piece
  TYPES = { 'P' => :pawn,
            'R' => :rook,
            'B' => :bishop,
            'N' => :horse,
            'G' => :gold,
            'S' => :silver, 
            'L' => :lance,
            'K' => :king }
  SYMBOLS = TYPES.invert
  
  def self.type_from_symbol(sym)
    promoted = sym[0,1] == '+'
    sym = sym[1..-1] if promoted
    type = TYPES[sym.upcase]
    type = ('promoted_' + type.to_s).to_sym if promoted
    type
  end
  
  def self.symbol(type)
    promoted = type.to_s =~ /^promoted_/
    base_type = if promoted
      type.to_s.gsub(/^promoted_/, '').to_sym
    else
      type
    end
    result = SYMBOLS[base_type] || '?'
    result = '+' + result if promoted
    result
  end
end

end
