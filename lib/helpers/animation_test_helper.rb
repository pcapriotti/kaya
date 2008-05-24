require 'animation_field'

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
