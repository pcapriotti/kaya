# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'rubygems'
require 'mocha'
require 'qtutils'

class TestQtUtils < Test::Unit::TestCase
  class Foo
    attr_reader :bar

    def initialize(bar)
      @bar = bar
    end

    def ==(other)
      self.bar == other.bar
    end
  end

  def test_painter_bracket
    p = Qt::Painter.new
    p.expects(:fill_rect).once
    p.expects(:end).once
    
    p.paint do |painter|
      painter.fill_rect
    end
  end
  
  def test_detect_index
    alphabet = ('a'..'z')
    h = alphabet.detect_index {|l| "hello"[0, 1] == l }
    
    assert_equal 7, h
    
    result = alphabet.detect_index {|l| 0 == 1 }
    assert_nil result
  end

  def test_qvariant_from_to_ruby
    hash = { :foo => ["bar", 4] }
    var = Qt::Variant.from_ruby(hash)
    assert_equal hash, var.to_ruby

    assert_equal Foo, Qt::Variant.from_ruby(Foo).to_ruby

    foo = Foo.new("bar")
    assert_equal foo, Qt::Variant.from_ruby(foo).to_ruby
  end
end
