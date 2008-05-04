require 'qtutils'

class Point
  include PrintablePoint
  attr_reader :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def ==(other)
    @x == other.x and @y == other.y
  end
end
