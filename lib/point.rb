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
  
  def =~(other)
    other.nil? or
    (((not other.x) or other.x == x) and
      ((not other.y) or other.y == y))
  end
  
  def to_coord(ysize)
    "#{(x + ?a).chr if x}#{(ysize - y) if y}"
  end
  
  def self.from_coord(s, ysize)
    if s =~ /^([a-zA-Z]?)(\d*)/
      letter = $1
      number = $2
      x = unless letter.empty? 
        if letter =~ /[a-z]/
          letter[0] - ?a
        else 
          letter[0] - ?A
        end
      end
      y = ysize - number.to_i unless number.empty?
      new x, y
    end
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
