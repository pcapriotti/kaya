# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'animation_field'
require 'factory'

module Animations
  LENGTH = 100
  
  def group(*animations)
    unless animations.empty?
      anim = animations.dup.compact
      return nil if anim.empty?
      name = case anim.size
      when 1
        anim.first.name
      else
        "group (#{anim.map{|a| a.to_s}.join(',')})"
      end
      Animation.new(name) do |i|
        anim.reject! do |a| 
          a[i]
        end
        anim.empty?
      end
    end
  end
  
  def sequence(*animations)
    anim = animations.dup.compact
    return nil if anim.empty?
    name = case anim.size
    when 1
      anim.first.name
    else
      "sequence (#{anim.map{|a| a.to_s}.join(',')})"
    end
    Animation.new(name) do |i|
      if anim.first[i]
        anim.shift
      end
      anim.empty?
    end
  end
  
  def movement(item, src, dst, path_factory)
    if item
      name = "move to #{dst}"
      src = if src
        board.to_real(src)
      else
        item.pos
      end
        
      dst = board.to_real(dst)
      path = path_factory.new(src, dst)
      
      SimpleAnimation.new name, LENGTH,
        lambda { board.raise(item) },
        lambda {|i| item.pos = src + path[i] },
        lambda { item.pos = dst; board.lower(item) }
    end
  end

  def disappear(item, name, opts = { })
    if item
      if opts[:instant]
        Animation.new(name) { item.visible = false; true }
      else
        SimpleAnimation.new name, LENGTH,
          lambda { item.opacity = 1.0; item.visible = true },
          lambda {|t| item.opacity = 1.0 - t },
          lambda { item.remove }
      end
    end
  end
  
  def appear(item, name, opts = { })
    if opts[:instant]
      Animation.new(name) { item.opacity = 1.0; item.visible = true; true }
    else
      SimpleAnimation.new name, LENGTH,
        lambda { item.opacity = 0.0; item.visible = true },
        lambda {|i| item.opacity = i },
        lambda { item.opacity = 1.0 }
    end
  end
end

module Path
  Linear = Factory.new do |src, dst|
    delta = dst - src
    lambda {|i| delta * i }
  end

  class LShape
    FACTOR = Math.exp(3.0) - 1
    def initialize(src, dst)
      @delta = dst - src
      nonlin = lambda{|i| (Math.exp(3.0 * i) - 1) / FACTOR }
      lin = lambda {|i| i }
      if @delta.x.abs < @delta.y.abs
        @x = lin
        @y = nonlin
      else
        @y = lin
        @x = nonlin
      end
    end
    
    def [](i)
      Qt::PointF.new(@delta.x * @x[i], @delta.y * @y[i])
    end
  end
end
