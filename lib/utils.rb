# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Object
  def tap
    yield self
    self
  end
  
  def alter(property)
    value = yield(send(property))
    send("#{property}=", value)
  end

  def metaclass
    class << self
      self
    end
  end
  
  def metaclass_eval(&blk)
    metaclass.instance_eval(&blk)
  end
  
  def map
    yield self unless nil?
  end
end


module Enumerable
  def detect_index
    i = 0
    each do |item|
      return i if yield item
      i += 1
    end
    
    nil
  end
end

class Hash
  def maph
    { }.tap do |result|
      each do |key, value|
        key, value = yield key, value
        result[key] = value
      end
    end
  end
end

class String
  def underscore
    self.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
         gsub(/([a-z\d])([A-Z])/,'\1_\2').
         downcase
  end
  
  def camelize
    gsub(/_(.)/) {|m| $1.upcase }
  end
end
