require 'animation_field'
require 'factory'

module Animations
  LENGTH = 100
  
  def group(*animations)
    anim = animations.dup.compact
    Animation.new("group (#{anim.size})") do |i|
      anim.reject! do |a| 
        a[i]
      end
      anim.empty?
    end
  end
  
  def sequence(*animations)
    anim = animations.dup.compact
    return nil if anim.empty?
    Animation.new("sequence (#{anim.size})") do |i|
      if anim.first[i]
        anim.shift
      end
      anim.empty?
    end
  end
  
  def movement(item, src, dst, path_factory)
    if item
      src = board.to_real(src)
      dst = board.to_real(dst)
      path = path_factory.new(src, dst)
      
      SimpleAnimation.new "move to #{dst}", LENGTH, nil,
        lambda {|i| item.pos = src + path[i] },
        lambda { item.pos = dst }
    end
  end

  def disappear(item, name = "disappear")
    if item
      SimpleAnimation.new name, LENGTH,
        lambda { item.opacity = 1.0; item.visible = true },
        lambda {|t| item.opacity = 1.0 - t },
        lambda { item.remove }
    end
  end
  
  def appear(item, name = "appear")
    SimpleAnimation.new name, LENGTH,
      lambda { item.opacity = 0.0; item.visible = true },
      lambda {|i| item.opacity = i },
      lambda { item.opacity = 1.0 }
  end
  
  def instant_appear(p, piece, name = "appear")
    Animation.new(name) { board.add_piece p, piece }
  end
  
  def instant_disappear(p, name = "disappear")
    Animation.new(name) { board.remove_item p }
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
