module Animations
  def group(*animations)
    anim = animations.dup
    lambda {|i| anim.reject! {|a| a[i] } }
  end
end
