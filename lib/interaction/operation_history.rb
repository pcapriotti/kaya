# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class OperationHistory
  attr_reader :current
  
  def initialize
    @operations = []
    @current = -1
  end
  
  def <<(op)
    @operations = @operations[0..@current]
    @operations << op
    @current += 1
  end
  
  def undo_operation
    if @current >= 0
      op = @operations[@current]
      @current -= 1
      op
    end
  end
  
  def redo_operation
    if @current < @operations.size
      @current += 1
      @operations[@current]
    end
  end
  
  def size
    @operations.size
  end
end
