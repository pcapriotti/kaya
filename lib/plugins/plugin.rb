# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Plugin
  module ModuleMethods
    def included(base)
      if base.class == Module
        base.extend ModuleMethods
      else
        base.extend ClassMethods
      end
      
      if $currently_loading_plugin_file
        base.instance_variable_set(
          "@main_plugin_file",
          $currently_loading_plugin_file)
      end
    end
  end
  
  module ClassMethods
    attr_reader :main_plugin_file
    
    def plugin(args)
      @plugin_data = args
    end
    
    def plugin_name
      @plugin_data[:name] if @plugin_data
    end
    
    def score(keywords)
      ((@plugin_data[:keywords] || []) & keywords).size
    end
    
    def implements?(iface)
      @plugin_data[:interface] == iface
    end
    
    def data(key)
      @plugin_data[key]
    end
    
    def base_dir
      File.dirname(main_plugin_file)
    end
  end
  
  extend ModuleMethods
  
  def keywords
    self.class.data(:keywords)
  end
end
