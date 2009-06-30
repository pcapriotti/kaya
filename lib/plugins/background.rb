# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Background
  HALO_DELTA = 0.1
  def halo(size, color)
    lines = [[[HALO_DELTA, HALO_DELTA], [1.0 - HALO_DELTA, HALO_DELTA]],
             [[HALO_DELTA, 1.0 - HALO_DELTA], [1.0 - HALO_DELTA, 1.0 -HALO_DELTA]],
             [[HALO_DELTA, HALO_DELTA], [HALO_DELTA, 1.0 - HALO_DELTA]],
             [[1.0 - HALO_DELTA, HALO_DELTA], [1.0 - HALO_DELTA, 1.0 - HALO_DELTA]]]
    img = Qt::Image.painted(size) do |p|
      lines.each do |src, dst|
        src = Qt::PointF.new(src[0] * size.x, src[1] * size.y)
        dst = Qt::PointF.new(dst[0] * size.x, dst[1] * size.y)
        p.pen = Qt::Pen.new(Qt::Brush.new(color), size.x * HALO_DELTA)
        p.draw_line Qt::LineF.new(src, dst)
      end
    end
    img.exp_blur(size.x * HALO_DELTA)
    img.to_pix
  end
  
  def selection(size)
    halo(size, Qt::Color.new(0xff, 0x40, 0x40))
  end
  
  def highlight(size)
    halo(size, Qt::Color.new(0x40, 0xff, 0x40))
  end
  
  def premove(size)
    halo(size, Qt::Color.new(0x40, 0x40, 0xff))
  end
  
  def flip(value)
  end
end
