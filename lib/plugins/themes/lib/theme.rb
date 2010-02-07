# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Theme
  def self.components
    [ :pieces, :board, :clock, :layout ]
  end
  
  attr_reader *components
  
  def initialize(opts = { })
    self.class.components.each do |component|
      instance_variable_set("@#{component}", opts[component])
    end
  end
end
