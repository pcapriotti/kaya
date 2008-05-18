require 'test/unit'
require 'animation_field'
require 'mocha'

class SimpleAnimationTest < Test::Unit::TestCase
  def test_init
    anim = SimpleAnimation.new "test", 10,
      mock("init") {|x| x.expects(:[]).once.with },
      mock("step") {|x| x.expects(:[]).once.with(0.0) },
      mock("post") {|x| x.expects(:[]).never }
    
    anim[34.43]
  end
  
  def test_phases
    phase = :not_started
    step_mock = mock("step") do |x|
      x.expects(:[]).once.with(0.0)
      x.expects(:[]).once.with(1.0)
    end
    
    anim = SimpleAnimation.new "test", 10, 
      mock("init") {|x| x.expects(:[]).once.with },
      step_mock,
      mock("post") {|x| x.expects(:[]).once.with }
    
    anim[10.0]
    anim[20.0]
  end
  
  def test_steps
    steps = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
    step_mock = mock("step") do |x|
      steps.each do |s|
        x.expects(:[]).once.with(s)
      end
    end
    anim = SimpleAnimation.new "test", 10, nil, step_mock
    start = 42.0
    steps.each do |s|
      anim[start + s * 10.0]
    end
  end
  
  def test_to_s
    anim = SimpleAnimation.new "hello", 10, nil, lambda {}
    assert_match /hello/, anim.to_s
  end
end
