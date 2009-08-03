# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'

class Item < Qt::GraphicsPixmapItem
  attr_reader :name, :item
  attr_reader :opacity
  
  # name is whatever information the caller needs
  # to recreate this piece with a different size
  # 
  def initialize(name, pixmap, parent)
    super(pixmap || Qt::Pixmap.new, parent)
    @name = name
    @opacity = 1.0
  end
  
  def paint(p, options, widget)
    if pixmap
      p.saving do |p|
        p.opacity = @opacity
        super p, options, widget
      end
    end
  end
  
  def opacity=(value)
    @opacity = value
    update
  end
  
  def remove
    scene.remove_item self
  end
end

class ReloadableItem < Item
  def initialize(name, reloader, parent)
    super(name, nil, parent)
    @reloader = reloader
  end
  
  def reload(key)
    @reloader[key, self]
  end
end

class AutoreloadableItem < Item
  def initialize(name, pix_loader, parent)
    super(name, nil, parent)
    @pix_loader = pix_loader
  end
  
  def set_geometry(rect)
    self.pos = rect.top_left.to_f
    self.pixmap = @pix_loader[rect.size]
  end
end

module ItemUtils
  BACKGROUND_ZVALUE = -10
  TEMP_ZVALUE = 10
  
  def create_item(opts)
    item_factory, arg = if opts[:reloader]
      [ReloadableItem, opts[:reloader]]
    elsif opts[:pix_loader]
      [AutoreloadableItem, opts[:pix_loader]]
    else
      [Item, opts[:pixmap]]
    end
    
    item = item_factory.new(opts[:name], arg, opts.fetch(:parent, item_parent))
    item.pos = opts[:pos] || Qt::PointF.new(0, 0)
    item.z_value = opts[:z] || 0
    item.visible = false if opts[:hidden]
    item
  end
  
  def destroy_item(item)
    scene.remove_item item
  end
  
  def raise(item)
    item.z_value = TEMP_ZVALUE
  end
  
  def lower(item)
    item.z_value = 0
  end
  
  def item_parent
    self
  end
end
