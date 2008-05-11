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
  
  def disappear(item, name = "disappear")
    if item
      SimpleAnimation.new "disappear", LENGTH,
        lambda { item.opacity = 1.0; item.visible = true },
        lambda {|t| item.opacity = 1.0 - t },
        lambda { item.remove }
    end
  end
  
  def disappear_on!(p, opts = {})
    name = "disappear on #{p}"
    if opts[:instant]
      Animation.new(name) { @board.remove_item p }
    else
      item = @board.remove_item(p, :keep)
      disappear(item, name)
    end
  end
  
  def appear(item, name = "appear")
    SimpleAnimation.new name, LENGTH,
      lambda { item.opacity = 0.0; item.visible = true },
      lambda {|i| item.opacity = i }  
  end
  
  def appear_on!(p, piece, opts = {})
    name = "appear #{piece} on #{p}"
    if opts[:instant]
      Animation.new(name) { @board.add_piece p, piece }
    else
      item = @board.add_piece p, piece, :hidden => true
      appear(item, name)
    end
  end
  
  def morph_on!(p, piece, opts = {})
    name = "morph to #{piece} on #{p}"
    if opts[:instant]
      Animation.new(name) { @board.add_piece p, piece }
    else
      old_item = @board.remove_item(p, :keep)
      new_item = @board.add_piece p, piece, :hidden => true
      group appear(new_item, name + " (appear)"),
            disappear(old_item, name + " (disappear)")
    end
  end
end
