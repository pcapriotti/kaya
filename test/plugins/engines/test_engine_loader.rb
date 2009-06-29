# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'plugins/loader'

class TestEngineLoader < Test::Unit::TestCase
  def setup
    @ploader = PluginLoader.new
    @loader = @ploader.get_matching(:engine_loader).new
  end
  
  def test_protocol_list
    assert_equal ['GNUShogi', 'XBoard'],
      @ploader.get_all_matching(:engine).
               map {|klass| klass.data(:protocol) }.
               uniq.sort
  end
end
