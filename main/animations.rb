module Animations
  LENGTH = 200
  
  def group(*animations)
    anim = animations.dup.compact
    lambda do |i|
      anim.reject! {|a| a[i] }
      anim.empty?
    end
  end
  
  def sequence(*animations)
    anim = animations.dup.compact
    return nil if anim.empty?
    lambda do |i|
      anim.shift if anim.first[i]
      anim.empty?
    end
  end
  
  def movement(item, move)
    if item
      src = @board.to_real move.src
      dst = @board.to_real move.dst
      delta = dst - src
      
      SimpleAnimation.new LENGTH, nil,
        lambda {|i| item.pos = src + delta * i },
        lambda { item.pos = dst }
    end
  end
  
  def disappear(item)
    if item
      SimpleAnimation.new LENGTH, nil,
        lambda {|i| item.opacity = 1.0 - i },
        lambda { item.remove }
    end
  end
  
  def appear(item)
    SimpleAnimation.new LENGTH, nil
      lambda {|i| item.opacity = 1.0 - i }  
  end
end
