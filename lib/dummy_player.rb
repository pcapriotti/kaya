# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class DummyPlayer
  include Observer
  include Player
  
  attr_reader :color
  attr_accessor :name
  
  def initialize(color)
    @color = color
  end
end
