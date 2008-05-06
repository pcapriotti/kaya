require 'qtutils'

class Point
  include PrintablePoint
  attr_reader :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def == other
    other and @x == other.x and @y == other.y
  end
  
  def + other
    self.class.new(@x + other.x, @y + other.y)
  end
  
  def - other
    self.class.new(@x - other.x, @y - other.y)
  end
  
  def * factor
    self.class.new(@x * factor, @y * factor)
  end
  
  def / factor
    self.class.new(@x / factor, @y / factor)
  end
  
  def eql?(other)
    other.instance_of?(Point) and self == other
  end
  
  def hash
    [@x, @y].hash
  end
  
  def unit
    Point.new(@x.unit, @y.unit)
  end
end

class PointRange
  include Enumerable
  
  attr_reader :src, :dst, :delta
  
  def initialize(src, dst)
    @src = src
    @dst = dst
    @delta = @dst - @src
    @increment = @delta.unit
  end
  
  def each
    current = @src
    while current != @dst
      yield current
      current += @increment
    end
  end
  
  def parallel?
    @delta.x == 0 or @delta.y == 0
  end
  
  def diagonal?
    @delta.x.abs == @delta.y.abs
  end
  
  def valid?
    parallel? or diagonal?
  end
end

class Numeric
  def unit
    self <=> 0
  end
end
