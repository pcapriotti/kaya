require 'games/chess/piece'

module Shogi

class Piece < Chess::Piece
  TYPES = { 'P' => :pawn,
            'R' => :rook,
            'B' => :bishop,
            'N' => :horse,
            'G' => :gold,
            'S' => :silver, 
            'L' => :lance }
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
