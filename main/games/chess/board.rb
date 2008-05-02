module Chess
  class Board
    attr_reader :size
  
    def initialize(size)
      @size = size
      @pieces = Array.new(@size.x * @size.y, nil)
    end
    
    def [](p)
      return nil unless valid? p
      @pieces[linear(p)]
    end
    
    def []=(p, value)
      if valid? p
        @pieces[linear(p)] = value
      end
    end
    
    def linear(p)
      p.x + @size.x * p.y
    end
    
    def valid?(p)
      p.x >= 0 && p.x < @size.x && p.y >= 0 && p.y < @size.y
    end
    
    def each_square
      (0...@size.x).each do |x|
        (0...@size.y).each do |y|
          yield Point.new(x, y)
        end
      end
    end
    
    def each_item
      each_square do |p|
        yield self[p] if self[p]
      end
    end
    
    def clear
      @pieces = Array.new(@size.x * @size.y, nil)
    end
  end
end
