require 'point'
require 'qtutils'

module PointConverter
  def to_logical(p)
    result = Point.new((p.x.to_f / unit.x).floor,
                       (p.y.to_f / unit.y).floor)
    result = flip_point(result) if flipped?
    result
  end
  
  def to_real(p)
    p = flip_point(p) if flipped?
    Qt::PointF.new(p.x * unit.x, p.y * unit.y)
  end
  
  def flip_point(p)
    Point.new(p.x,
              state.board.size.y - p.y - 1)
  end
end
