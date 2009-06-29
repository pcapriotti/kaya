# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Shadower
  ShadowData = Struct.new(:radius, :color, :grow, :offset)
  DEFAULT_SHADOW_DATA = 
    ShadowData.new(7.0, Qt::Color.new(0x40, 0x40, 0x50), 5, Qt::PointF.new(6, 4))
  
  def with_shadow(loader, data = DEFAULT_SHADOW_DATA)
    lambda do |piece, size|
      isz = size * 100 / (100 + data.grow) + Qt::Point.new(0.5, 0.5)
      off = Qt::Point.new(
        data.offset.x * isz.x / 200.0,
        data.offset.y * isz.x / 200.0)
      img = loader[piece, isz]
      scaled_data = ShadowData.new(data.radius * isz.x / 100.0,
                                   data.color,
                                   size.x - isz.x,
                                   off)
      s = shadow(img, scaled_data)
      Qt::Painter.new(s).paint do |p|
        dst = Qt::Rect.new((size.x - isz.x) / 2 - off.x,
                            (size.y - isz.y) / 2 - off.y,
                            isz.x, isz.y)
        p.draw_image(dst, img, Qt::Rect.new(Qt::Point.new(0, 0), isz))
      end
      s
    end
  end
  
  private
  
  def shadow(img, data)
    img = Qt::Image.painted(Qt::Point.new(img.width + data.grow, 
                                          img.height + data.grow)) do |p|
      px = (data.grow * 0.5 + data.offset.x).to_i
      py = (data.grow * 0.5 + data.offset.y).to_i
  
      p.composition_mode = Qt::Painter::CompositionMode_Source
      p.fill_rect Qt::Rect.new(px, py, img.width, img.height), data.color
      p.composition_mode = Qt::Painter::CompositionMode_DestinationAtop
      p.draw_image Qt::Point.new(px, py), img
    end
    img.exp_blur(data.radius)
    img
  end
end
