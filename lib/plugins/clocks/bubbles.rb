# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'plugins/plugin'
require 'board/item_bag'
require 'observer_utils'
require_bundle 'clocks', 'clock_display'

class BubblesClock < Qt::GraphicsItemGroup
  include Plugin
  include ItemBag
  include ItemUtils
  include Observer
  include ClockDisplay
  
  plugin :name => 'Bubbles Clock Skin',
         :interface => :clock2

  attr_reader :items, :rect, :clock
  
  BASE_DIR = File.dirname(__FILE__)
  ACTIVE_SKIN_RENDERER = Qt::SvgRenderer.new(
      File.join(BASE_DIR, 'active_clock.svg'))
  INACTIVE_SKIN_RENDERER = Qt::SvgRenderer.new(
      File.join(BASE_DIR, 'inactive_clock.svg'))
          
  def initialize(scene)
    super(nil, @scene = scene)
    @items = create_display_items
    @active = false
  end
  
  def redraw
    if @rect
      add_item :skin, 
               :pixmap => skin, 
               :z => BACKGROUND_ZVALUE
      @items[:time].constraint = Qt::RectF.new(
        @rect.width * 0.4, @rect.height * 0.1, 
        @rect.width * 0.6, @rect.height * 0.62)
      @items[:caption].constraint = Qt::RectF.new(
        @rect.width * 0.02, @rect.height * 0.22,
        @rect.width * 0.4, @rect.height * 0.38)
      @items[:player].constraint = Qt::RectF.new(
        @rect.width * 0.14, @rect.height * 0.68,
        @rect.width * 0.69, @rect.height * 0.28)
    end
  end

  def skin
    renderer = if @active
      ACTIVE_SKIN_RENDERER
    else
      INACTIVE_SKIN_RENDERER
    end
    Qt::Image.from_renderer(@rect.size, renderer).to_pix
  end
end
