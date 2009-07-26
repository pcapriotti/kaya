# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Proc
  def bind(object)
    block, time = self, Time.now
    (class << object; self end).class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end

class Factory
  attr_reader :component

  def initialize(klass = nil, &blk)
    @blk = blk
    @component = klass
  end
  
  def new(*args)
    @blk[*args]
  end
  
  def __bind__(object)
    Factory.new(@component, &@blk.bind(object))
  end
end
