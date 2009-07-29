# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Redrawable
  def piece_reloader(piece)
    lambda do |p, item|
      item.pixmap = theme.pieces.pixmap(piece, unit)
      item.pos = to_real(p)
    end
  end
  
  def background_reloader
    lambda do |key, item|
      item.pixmap = theme.board.pixmap(unit)
    end
  end
end
