# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

# A NinePatchItem is rectangular item composed of 9 subitems, 
# 4 at the sides, 4 at the corners, and one in the center.
# Subitems are specified in the items hash, with keys: 
# :n, :w, :s, :e for the sides; 
# :ne, :nw, :sw, :se for the corners;
# :center for the center.
# Subitems must respond to set_geometry.
# 
class NinePatchItem < Qt::GraphicsItemGroup
  attr_reader :bsize
  
  def initialize(parent, scene, items)
    super(parent, scene)
    @items = items
    @bsize = 1
    @items.each do |key, item|
      item.group = self
    end
  end
  
  def bsize=(value)
    @bsize = value.to_i
  end
  
  def set_geometry(rect)
    self.pos = rect.top_left.to_f
    g = lambda do |key, x, y, w, h|
      if @items[key]
        @items[key].set_geometry(Qt::Rect.new(x, y, w, h))
      end
    end
    g[:nw, 0, 0, @bsize, @bsize]
    g[:n, @bsize, 0, rect.width - @bsize * 2, @bsize]
    g[:ne, rect.width - @bsize, 0, @bsize, @bsize]

    g[:sw, 0, rect.height - @bsize, @bsize, @bsize]
    g[:s, @bsize, rect.height - @bsize, rect.width - @bsize * 2, @bsize]
    g[:se, rect.width - @bsize, rect.height - @bsize, @bsize, @bsize]

    g[:w, 0, @bsize, @bsize, rect.height - @bsize * 2]
    g[:center, @bsize, @bsize, rect.width - @bsize * 2, rect.height - @bsize * 2]
    g[:e, rect.width - @bsize, @bsize, @bsize, rect.height - @bsize * 2]
  end
end
