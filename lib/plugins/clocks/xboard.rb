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

class XBoardClock < Qt::GraphicsItemGroup
  include Plugin
  include ItemBag
  include ItemUtils
  include Observer
  include ClockDisplay
  
  plugin :name => 'XBoard Clock Skin',
         :interface => :clock

  attr_reader :items, :rect, :clock
  
  OFF_TEXT = '-'
          
  def initialize(scene)
    super(nil, @scene = scene)
    @items = create_display_items
    @active = false
  end
    
  def redraw
    if @rect
      add_item :skin, skin, :z => BACKGROUND_ZVALUE
      text_color = Qt::Color.new(@active ? Qt::white : Qt::black)
      @items[:time].constraint = Qt::RectF.new(
        @rect.width * 0.4, @rect.height * 0.05, 
        @rect.width * 0.7, @rect.height * 0.8)
      @items[:caption].constraint = Qt::RectF.new(
        0, @rect.height * 0.1,
        @rect.width * 0.5, @rect.height * 0.7)
      @items[:player].constraint = Qt::RectF.new(
        0, @rect.height * 0.68,
        @rect.width, @rect.height * 0.28)
        
      @items.each do |name, item|
        if item.respond_to? 'color='
          item.color = text_color
        end
      end
    end
  end
  
  def skin
    color = Qt::Color.new(@active ? Qt::black : Qt::white)
    Qt::Image.painted(@rect.size) do |p|
      p.fill_rect(Qt::RectF.new(Qt::PointF.new(0, 0), @rect.size), 
                  color)
      p.alter(:pen) {|pen| pen.width = 2; pen.style = Qt::SolidLine }
      p.draw_line(0, 0, @rect.width, 0)
      p.draw_line(0, 0, 0, @rect.height)
      p.draw_line(@rect.width - 1, 0, @rect.width - 1, @rect.height)
      p.draw_line(0, @rect.height - 1, @rect.width, @rect.height - 1)
    end.to_pix
  end
end
