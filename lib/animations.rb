require 'animation_field'

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
  
  def movement(item, src, dst)
    if item
      src = board.to_real(src)
      dst = board.to_real(dst)
      delta = dst - src
      
      SimpleAnimation.new "move to #{dst}", LENGTH, nil,
        lambda {|i| item.pos = src + delta * i },
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
