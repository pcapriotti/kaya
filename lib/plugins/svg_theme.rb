# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require 'plugins/plugin'
require 'plugins/shadow'

class SvgTheme
  include Shadower

  def initialize(opts = {})
    @loader = lambda do |piece, size|
      Qt::Image.from_renderer(size, renderer, piece_id(piece))
    end
    if opts.fetch(:shadow, true)
      @loader = with_shadow(@loader)
    end
  end

  def pixmap(piece, size)
    @loader[piece, size].to_pix
  end
  
  def renderer
    @renderer ||= create_renderer
  end
  
  def create_renderer
    Qt::SvgRenderer.new(filename)
  end
  
  def piece_id(piece)
    piece.color.to_s.capitalize + piece.type.to_s.capitalize
  end
  
  def flip(value)
  end
end
