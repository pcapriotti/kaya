# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require 'plugins/svg_theme'

class FantasyPieces < SvgTheme
  include Plugin
  plugin :name => 'Fantasy Pieces',
         :interface => :pieces,
         :keywords => %w(chess),
         :bundle => 'fantasy'

  def initialize(opts = {})
    super(opts)
  end

  def filename
    rel('fantasy.svg')
  end
end
