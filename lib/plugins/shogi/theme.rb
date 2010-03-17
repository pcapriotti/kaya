# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require 'plugins/plugin'
require 'plugins/shadow'
require 'plugins/background'
require_bundle 'shogi', 'type'

class ShogibanBackground
  include Plugin
  include Background
  
  BACKGROUND_COLOR = Qt::Color.new(0xeb, 0xd6, 0xa0)
  LINE_COLOR = Qt::Color.new(0x9c, 0x87, 0x55)
  
  plugin :name => 'Shogiban',
         :interface => :board,
         :keywords => %w(shogi),
         :bundle => 'shogi'
        
  def initialize(opts = {})
    @squares = opts[:board_size] || opts[:game].size
    @background = opts[:background] || 'kaya'
  end
  
  def pixmap(size)
    Qt::Image.painted(Qt::Point.new(size.x * @squares.x, size.y * @squares.y)) do |p|
      if @background
        bg = Qt::Image.new(rel('pics', @background + '.png'))
        p.draw_tiled_pixmap(Qt::Rect.new(0, 0, size.x * @squares.x, size.y * @squares.y), bg.to_pix)
      else
        (0...@squares.x).each do |x|
          (0...@squares.y).each do |y|
            rect = Qt::RectF.new(size.x * x, size.y * y, size.x, size.y)
            p.fill_rect(rect, Qt::Brush.new(BACKGROUND_COLOR))
          end
        end
      end
      pen = p.pen
      pen.width = 2
      pen.color = LINE_COLOR
      p.pen = pen
      (0..@squares.x).each do |x|
        p.draw_line(x * size.x, 0, x * size.x, @squares.y * size.y)
      end
      (0..@squares.y).each do |y|
        p.draw_line(0, y * size.y, size.x * @squares.x, y * size.y)
      end
    end.to_pix
  end
end

class ShogiPieces
  include Plugin
  include Shadower

  plugin :name => 'Shogi Pieces',
         :interface => :pieces,
         :keywords => %w(shogi),
         :bundle => 'shogi'
  
  TYPES = { :knight => 'n' }
  NUDE_TILE = rel('pics', 'nude_tile.svg')
  RATIOS = {
    :king => 1.0,
    :rook => 0.96,
    :bishop => 0.93,
    :gold => 0.9,
    :silver => 0.9,
    :knight => 0.86,
    :lance => 0.83,
    :pawn => 0.8 }

  def initialize(opts = {})
    @loader = lambda do |piece, size|
      tile = Qt::SvgRenderer.new(NUDE_TILE)
      kanji = Qt::SvgRenderer.new(filename(piece))
      ratio = RATIOS[piece.type] || 0.9
      img = Qt::Image.painted(size) do |p|
        p.scale(ratio, ratio)
        p.translate(size * (1 - ratio) / 2)
        if (piece.color == :white) ^ @flipped
          p.translate(size)
          p.rotate(180)
        end
        tile.render(p)
        kanji.render(p)
      end
    end
    if opts.has_key? :shadow
      @loader = with_shadow(@loader)
    end
    @flipped = false
  end

  def pixmap(piece, size)
    @loader[piece, size].to_pix
  end
  
  def filename(piece)
    color = piece.color.to_s[0, 1]
    name = Promoted.demote(piece.type).to_s + ".svg"
    name = 'p' + name if Promoted.promoted?(piece.type)
    rel('pics', name)
  end
  
  def flip(value)
    @flipped = value
  end
end
