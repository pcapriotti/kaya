module Chess
  class Piece
    attr_reader :color, :type
    SYMBOLS = { :knight => 'n' }
  
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
      s = SYMBOLS[type] || type.to_s[0, 1].downcase
      s.upcase! if color == :white
      s
    end
  end
end