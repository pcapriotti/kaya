require 'point'
require 'enumerator'

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
    
    def clear_path?(path)
      path.all? {|p| p == path.src or not self[p] }
    end
    
    def to_s
      (@size.y - 1).to_enum(:downto, 0).map do |y|
        (0...@size.x).map do |x| 
          (piece = self[Point.new(x, y)]) ? piece.symbol : ' '
        end.join(' ')
      end.join("\n")
    end
  end
end
