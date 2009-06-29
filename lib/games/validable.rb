# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Validable
  attr_writer :valid
  
  def valid?
    @valid
  end
  
  def validated?
    @valid != nil
  end
  
  def validate
    if validated?
      valid?
    else
      self.valid = yield self
    end
  end
end
