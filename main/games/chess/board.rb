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
end