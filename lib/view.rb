# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class View
  include Observable
  
  attr_reader :controller, :movelist, :table
  attr_reader :active
  
  def initialize(table, controller, movelist)
    @table = table
    @controller = controller
    @movelist = movelist
    @closed = false
    @controller.on(:activity) { self.active = true }
  end
  
  def main_widget
    @table
  end
  
  def close
    @closed = true
    fire :close
  end
  
  def closed?
    @closed
  end
  
  def active=(value)
    @active = value
    fire :active => [self, value]
  end
end
