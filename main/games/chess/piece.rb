module Chess
  class Piece
    attr_reader :color, :type
  
    def initialize(color, type)
      @color = color
      @type = type
    end
    
    def ==(other)
      @color == other.color and @type == other.type
    end
  end
end