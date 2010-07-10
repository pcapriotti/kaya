# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'enumerator'

class PluginLoader
  BASE_DIR = File.expand_path(File.dirname(__FILE__))
  
  NoPluginFound = Class.new(Exception)
  include Enumerable
  
  def setup
    # load all ruby files in subdirectories
    Dir[File.join(BASE_DIR, '*')].each do |f|
      if File.directory?(f)
        Dir[File.join(f, '*.rb')].each do |rb_file|
          load(rb_file)
        end
      end
    end
    
    @plugins = ObjectSpace.
               to_enum(:each_object, Class).
               select do |k|
      k.include?(Plugin) and k.plugin_name
    end
  end
  
  def each(&blk)
    @plugins.each(&blk)
  end
  
  def get_matching(interface, keywords = [])
    plugins = get_all_matching(interface).
      sort_by {|x| x.score(keywords) }
      
    raise NoPluginFound.new("No plugins matching interface #{interface}") if plugins.empty?
    plugins.last
  end
  
  def get_all_matching(interface)
    @plugins.reject {|x| not x.implements?(interface) }
  end
  
   # singleton
  class << self
    alias :internal_new :new
    
    def new
      unless @instance
        @instance = PluginLoader.internal_new
        @instance.setup
      end
      @instance
    end
  end
  
  def self.base_dir
    BASE_DIR
  end
end
