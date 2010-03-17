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
  
  def shadow_effect(size, data = DEFAULT_SHADOW_DATA)
    Qt::GraphicsDropShadowEffect.new.tap do |effect|
      isz = size * 100 / (100 + data.grow) + Qt::Point.new(0.5, 0.5)
      off = Qt::PointF.new(
        data.offset.x * isz.x / 200.0,
        data.offset.y * isz.x / 200.0)
      effect.blur_radius = data.radius * isz.x / 100.0
      effect.color = data.color
      effect.offset = off
    end
  end
end
