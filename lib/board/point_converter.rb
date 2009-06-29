# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

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
    Point.new(@game.size.x - p.x - 1, @game.size.y - p.y - 1)
  end
end
