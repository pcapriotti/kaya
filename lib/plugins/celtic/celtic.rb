# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'plugins/svg_theme'

class CelticTheme < SvgTheme
  include Plugin
  plugin :name => 'Celtic Pieces',
         :interface => :pieces,
         :keywords => %w(chess)

  def initialize(opts = {})
    super(opts)
  end

  def filename
    File.join(File.dirname(__FILE__), 'celtic.svg')
  end
end
