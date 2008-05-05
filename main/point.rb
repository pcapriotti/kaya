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
  
  def +(other)
    self.class.new(@x + other.x, @y + other.y)
  end
  
  def -(other)
    self.class.new(@x - other.x, @y - other.y)
  end
  
  def eql?(other)
    other.instance_of?(Point) and self == other
  end
  
  def hash
    [@x, @y].hash
  end
end
