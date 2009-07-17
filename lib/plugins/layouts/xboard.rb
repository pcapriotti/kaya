# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class XBoardLayout
  include Plugin
  
  plugin :name => 'XBoard Layout',
         :interface => :layout
        
  # values relative to unit = 1
  MARGIN = 0.2
  POOL_WIDTH = 2.6
  CLOCK_HEIGHT_RATIO = 0.2
        
  def initialize(game)
    @game = game
    @size = @game.size
    @flipped = false
  end
        
  def layout(rect, elements)
    has_pools = ! elements[:pools].empty?
    xrel = @size.x + MARGIN * 2 + (has_pools ? POOL_WIDTH + MARGIN : 0)
    clock_width_rel = @size.x. / @game.players.size.to_f
    clock_height_rel = clock_width_rel * CLOCK_HEIGHT_RATIO
    yrel = @size.y + MARGIN * 2 + clock_height_rel
    unit = [rect.width / xrel, rect.height / yrel].min.floor
    
    margin = (MARGIN * unit).to_i
    clock_width = (clock_width_rel * unit).to_i
    clock_height = (clock_height_rel * unit).to_i
    pool_width = POOL_WIDTH * unit
    
    base = Qt::Point.new((rect.width - xrel * unit) / 2,
                          (rect.height - yrel * unit) / 2)
    
    # board
    board_rect = Qt::Rect.new(
      base.x + margin, base.y + margin + clock_height,
      @size.x * unit, @size.y * unit)
    elements[:board].flip(@flipped)
    elements[:board].set_geometry(board_rect)

    # pools
    if has_pools
      pool_height = (board_rect.height - margin * (@game.players.size - 1)) / 
                    @game.players.size
      offy = base.y
      players = @game.players
      players = players.reverse unless @flipped
      flip = false
      players.each do |player|
        pool_rect = Qt::Rect.new(
          board_rect.right + margin,
          offy + margin,
          pool_width,
          pool_height - margin)
        elements[:pools][player].flip(flip)
        elements[:pools][player].set_geometry(pool_rect)
        offy += margin + pool_height
        flip = !flip
      end
    end
    
    # clocks
    offx = base.x + margin
    @game.players.each do |player|
      clock_rect = Qt::Rect.new(
        offx, base.y + margin,
        clock_width, clock_height)
      elements[:clocks][player].set_geometry(clock_rect)
      offx = clock_rect.right + 1
    end
  end
  
  def flip(value)
    @flipped = value
  end
  
  def flipped?
    @flipped
  end
end
