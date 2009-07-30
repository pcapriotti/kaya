# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module TaggableSquares
  TAGS_ZVALUE = -2
  
  module ClassMethods
    def square_tag(name, element, opts = {})
      define_method(name) do
        instance_variable_get("@#{name}")
      end
      
      define_method("#{name}=") do |val|
        tag_pixmap = lambda { theme.board.send(element, unit) }
        tag_reloader = lambda do |key, item|
          item.pixmap = tag_pixmap[]
          item.pos = to_real(val)
        end
        
        instance_variable_set("@#{name}", val)
        if val
          options = { :pos => to_real(val),
                      :z => TAGS_ZVALUE,
                      :reloader => tag_reloader }.merge(opts)
          square_tag_container.add_item(
            name,
            tag_pixmap[], 
            options)
        else
          square_tag_container.remove_item(name)
        end
      end
    end
  end
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  alias :tag :send
  
  def set_tag(name, value)
    send("#{name}=", value)
  end
  
  def square_tag_container
    self
  end
end


