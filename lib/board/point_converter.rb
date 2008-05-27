require 'point'
require 'qtutils'

module PointConverter  
  def to_logical(p)
    Point.new((p.x.to_f / unit.x).floor,
              (p.y.to_f / unit.y).floor)
  end
  
  def to_real(p)
    Qt::PointF.new(p.x * unit.x, p.y * unit.y)
  end
end
