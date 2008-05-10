module Animations
  LENGTH = 200
  
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
      src = @board.to_real(src)
      dst = @board.to_real(dst)
      delta = dst - src
      
      SimpleAnimation.new "move to #{dst}", LENGTH, nil,
        lambda {|i| item.pos = src + delta * i },
        lambda { item.pos = dst }
    end
  end
  
  def move!(src, dst)
    piece = @board.move_item(src, dst)
    movement(piece, src, dst)
  end
  
  def disappear(item)
    if item
      SimpleAnimation.new "disappear", LENGTH, nil,
        lambda {|i| item.opacity = 1.0 - i },
        lambda { item.remove }
    end
  end
  
  def disappear_on!(p)
    piece = @board.remove_item(p, :keep)
    disappear(piece)
  end
  
  def appear(item)
    SimpleAnimation.new "appear", LENGTH, nil
      lambda {|i| item.opacity = 1.0 - i }  
  end
end
