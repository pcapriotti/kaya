# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'require_bundle'

module Plugin
  module ModuleMethods
    def included(base)
      if base.class == Module
        base.extend ModuleMethods
      else
        base.extend ClassMethods
      end
    end
  end
  
  module Bundle
    BASE_PLUGIN_PATH = File.expand_path(File.dirname(__FILE__))
    def bundle_rel(bundle, *args)
      File.join(BASE_PLUGIN_PATH, bundle, *args)
    end
    
    def rel(*args)
      bundle_rel(bundle, *args)
    end
  end
  
  module ClassMethods
    include Bundle
    attr_reader :bundle_dir
    
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

    def bundle
      @plugin_data[:bundle] or
      raise("No bundle specified")
    end
  end
  
  extend ModuleMethods
  include Bundle
  
  def keywords
    self.class.data(:keywords)
  end
  
  def bundle
    self.class.bundle
  end
end
