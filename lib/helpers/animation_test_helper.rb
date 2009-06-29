# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'animation_field'
require 'board/item_bag'
require 'board/point_converter'

class FakeAnimationField < AnimationField
  class FakeTimer
    def self.every(interval)
    end
  end
  
  def initialize
    super(nil, FakeTimer)
  end
    
  def run_test
    i = 0.0
    while not @actions.empty?
      tick(i.to_f)
      i += 1
    end
  end
end

class FakeBoard
  include ItemBag
  attr_reader :items
  
  def initialize(items)
    @items = items
    @unit = Point.new(10, 10)
  end
  
  def add_piece(p, piece, opts = {})
    add_item p, piece
  end
  
  def create_item(key, piece)
    piece
  end
  
  def destroy_item(piece)
  end
end

class FakeAnimation
  attr_reader :animation, :args
  def initialize(animation, args)
    @animation = animation
    @args = args
  end
  
  def <=>(other)
    animation.to_s <=> other.animation.to_s
  end
  
  def to_s
    "#{animation}(#{args.join(', ')})"
  end
end

module StubbedAnimations
  def self.stub_methods(*methods)
    methods.each do |method|
      eval %{
        def #{method}(*args)
          FakeAnimation.new(:#{method}, args)
        end
      }
    end
  end
  stub_methods :group, :appear, :disappear, :instant_appear, 
                :instant_disappear, :movement, :sequence
end

module AnimationAssertions
  def assert_animation(type, x)
    assert_equal type, x.animation
    yield x.args.compact if block_given?
  end
end