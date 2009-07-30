# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class ThemeComponentStub
  def method_missing(m, *args)
    img = Qt::Image.painted(Qt::Point.new(1, 1)) { }
    img.to_pix
  end
  
  def respond_to?(m)
    true
  end
end

class ThemeStub
  def initialize
    @stub = ThemeComponentStub.new
  end
  
  def method_missing(comp)
    @stub
  end
  
  def respond_to?(comp)
    true
  end
end
