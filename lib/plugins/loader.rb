# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class PluginLoader
  BASE_DIR = File.expand_path(File.dirname(__FILE__))
  
  NoPluginFound = Class.new(Exception)
  
  def initialize
    # load all ruby files in subdirectories
    Dir[File.join(BASE_DIR, '*')].each do |f|
      if File.directory?(f)
        Dir[File.join(f, '*.rb')].each do |rb_file|
          $currently_loading_plugin_file = rb_file
          require rb_file
        end
      end
    end
    $currently_loading_plugin_file = nil
    
    @plugins = {}
    ObjectSpace::each_object(Class) do |k|
      if k.include?(Plugin) and k.plugin_name
        @plugins[k.plugin_name] = k
      end
    end
  end
  
  def each(&blk)
    @plugins.each_value(&blk)
  end
  
  def get_matching(interface, keywords = [])
    plugins = get_all_matching(interface).
      sort_by {|x| x.score(keywords) }
      
    raise NoPluginFound if plugins.empty?
    plugins.last
  end
  
  def get_all_matching(interface)
    @plugins.values.reject {|x| not x.implements?(interface) }
  end
  
   # singleton
  class << self
    alias :internal_new :new
    
    def new
      @instance ||= PluginLoader.internal_new
    end
  end
end
