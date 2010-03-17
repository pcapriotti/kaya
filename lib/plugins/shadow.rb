# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Shadower
  ShadowData = Struct.new(:radius, :color, :grow, :offset)
  DEFAULT_SHADOW_DATA = 
    ShadowData.new(14.0, Qt::Color.new(0x40, 0x40, 0x50), 5, Qt::PointF.new(6, 4))
  
  def with_shadow(loader, data = DEFAULT_SHADOW_DATA)
    lambda do |piece, size|
      isz = size * 100 / (100 + data.grow) + Qt::Point.new(0.5, 0.5)
      off = Qt::Point.new(
        data.offset.x * isz.x / 200.0,
        data.offset.y * isz.x / 200.0)
      img = loader[piece, isz]
      pix = Qt::Image.painted(Qt::Point.new(img.width + data.grow,
                                            img.height + data.grow)) do |p|
        dst = Qt::Rect.new((size.x - isz.x) / 2 - off.x,
                            (size.y - isz.y) / 2 - off.y,
                            isz.x, isz.y)
        p.draw_image(dst, img, Qt::Rect.new(Qt::Point.new(0, 0), isz))
      end.to_pix
      pix.add_effect(shadow(data, size))
      pix
    end
  end
  
  private
  
  def shadow(data, size)
    Qt::GraphicsDropShadowEffect.new.tap do |effect|
      effect.blur_radius = data.radius # * 100 / (100 + data.grow)
      effect.color = data.color
      effect.offset = data.offset * 100 / (100 + data.grow)
    end
  end
end

