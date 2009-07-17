# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Theme
  attr_reader :pieces, :board,
              :clock, :layout
  
  def initialize(opts = { })
    @pieces = opts[:pieces]
    @board = opts[:board]
    @clock = opts[:clock]
    @layout = opts[:layout]
  end
end
