# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'plugins/background'

class XBoardBackground
  include Plugin
  include Background
  
  plugin :name => 'XBoard Background',
         :interface => :board,
         :keywords => %w(chess)
  
  def initialize(opts)
    @squares = opts[:board_size] || opts[:game].size
  end

  def pixmap(size)
    Qt::Image.painted(Qt::Point.new(size.x * @squares.x, size.y * @squares.y)) do |p|
      (0...@squares.x).each do |x|
        (0...@squares.y).each do |y|
          rect = Qt::RectF.new(size.x * x, size.y * y, size.x, size.y)
          color = if (x + y) % 2 == 1
            Qt::Color.new(0x73, 0xa2, 0x6b)
          else
            Qt::Color.new(0xc6, 0xc3, 0x63)
          end
          p.fill_rect(rect, Qt::Brush.new(color))
        end
      end
      
      pen = p.pen
      pen.width = 2
      pen.color = Qt::Color.new(Qt::black)
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