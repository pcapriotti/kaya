# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'animations'

module AnimatorHelper
  include Animations
  
  def move!(src, dst, path, opts = {})
    piece = board.move_item(src, dst)
    src = nil if opts[:adjust]
    movement(piece, src, dst, path)
  end
  
  def disappear_on!(p, opts = {})
    name = "disappear on #{p}"
    item = board.remove_item(p, :keep)
    disappear(item, name, opts)
  end
    
  def appear_on!(p, piece, opts = {})
    name = "appear #{piece} on #{p}"
    item = board.add_piece p, piece, :hidden => true
    appear(item, name, opts)
  end
  
  def morph_on!(p, piece, opts = {})
    name = "morph to #{piece} on #{p}"
    old_item = board.remove_item(p, :keep)
    new_item = board.add_piece p, piece, :hidden => true
    group appear(new_item, name + " (appear)", opts),
          disappear(old_item, name + " (disappear)", opts)
  end
end
