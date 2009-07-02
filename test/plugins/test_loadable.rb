# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'plugins/loader'
require 'rbconfig'

class TestLoadable < Test::Unit::TestCase
  RUBY_EXE = Config::CONFIG['ruby_install_name']

  def test_load_plugins
    plugins = PluginLoader.base_dir
    lib = File.join(plugins, '..')
    
    Dir[File.join(plugins, '*')].each do |f|
      if File.directory?(f)
        Dir[File.join(f, '*.rb')].each do |rb_file|
          `#{RUBY_EXE} -I#{lib} #{rb_file}`
          assert_equal 0, $?
        end
      end
    end
  end
  
end
      
