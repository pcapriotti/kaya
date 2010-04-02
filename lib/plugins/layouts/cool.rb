# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'item'
require 'nine_patch_item'

class CoolLayout
  include Plugin
  include ItemUtils
  
  plugin :name => 'Cool Layout',
         :interface => :layout
        
  # values relative to unit = 1
  MARGIN = 0.2
  CLOCK_WIDTH = 2.6
  CLOCK_HEIGHT_RATIO = 0.4
  BOARD_FRAME = 0.4
        
  def initialize(game)
    @game = game
    @size = @game.size
    @flipped = false
    @renderer = Qt::SvgRenderer.new(rel('cool.svg'))
  end
  
  def setup(elements)
    board = elements[:board]
    items = {}
    [:ne, :n, :nw, :e, :w, :se, :s, :sw].each do |key|
      items[key] = create_item(
        :pix_loader => lambda{|size|
          Qt::Image.from_renderer(size, @renderer, key.to_s).to_pix }).
          tap{|item| board.scene.add_item(item) }
    end
    items[:center] = board
    elements[:board_frame] = NinePatchItem.new(nil, board.scene, items)
  end
        
  def layout(rect, elements)
    xrel = @size.x + BOARD_FRAME * 2 + MARGIN * 3 + CLOCK_WIDTH
    yrel = @size.y + BOARD_FRAME * 2 + MARGIN * 2
    unit = [rect.width / xrel, rect.height / yrel].min.floor
    margin = MARGIN * unit
    clock_width = CLOCK_WIDTH * unit
    clock_height = clock_width * CLOCK_HEIGHT_RATIO

    base = Qt::Point.new((rect.width - xrel * unit) / 2,
                          (rect.height - yrel * unit) / 2)
    frame = BOARD_FRAME * unit
    
    elements[:board].flip(@flipped)
    board_rect = Qt::Rect.new(
      base.x + margin, base.y + margin,
      @size.x * unit + frame * 2, @size.y * unit + frame * 2)
    elements[:board_frame].bsize = frame
    elements[:board_frame].set_geometry(board_rect)

    pool_height = (board_rect.height - margin * (@game.players.size - 1)) / 
                  @game.players.size
    offy = base.y
    flip = false
    players = @game.players
    players = players.reverse unless @flipped
    players.each do |player|
      r_pool, r_clock = if flip
        [Qt::Rect.new(
            board_rect.right + margin,
            offy + margin,
            clock_width,
            pool_height - clock_height - margin),
          Qt::Rect.new(
            board_rect.right + margin,
            offy + margin + pool_height - clock_height,
            clock_width,
            clock_height)]
      else
        [Qt::Rect.new(
            board_rect.right + margin,
            offy + margin * 2 + clock_height,
            clock_width,
            pool_height - clock_height - margin),
          Qt::Rect.new(
            board_rect.right + margin,
            offy + margin,
            clock_width,
            clock_height)]
      end
      unless elements[:pools].empty?
        elements[:pools][player].flip(flip)
        elements[:pools][player].set_geometry(r_pool)
      end
      elements[:clocks][player].set_geometry(r_clock)
      offy = offy + margin + pool_height
      flip = !flip
    end
  end
  
  def flip(value)
    @flipped = value
  end
  
  def flipped?
    @flipped
  end
  
  def item_parent
    nil
  end
end
