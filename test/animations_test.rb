require 'test/unit'
require 'animations'
require 'helpers/animation_test_helper'
require 'helpers/stubs'

class AnimationContainer
  include Animations
end

class AnimationsTest < Test::Unit::TestCase
  def setup
    @field = FakeAnimationField.new
    @c = AnimationContainer.new
  end
  
  def test_disappear
    item = GeneralMock.new
    @field.run @c.disappear(item)
    @field.run_test
    
    assert_equal [:opacity=, [1.0]], item.calls.shift
    assert_equal [:visible=, [true]], item.calls.shift
    
    old_op = 1.0
    while old_op > 0.0
      method, args = item.calls.shift
      break unless method == :opacity=
      assert_operator args.first, :<=, old_op
      old_op = args.first
    end
    
    assert_equal [:remove, []], item.calls.shift
    assert_equal [], item.calls
  end
  
  def test_appear
    item = GeneralMock.new
    @field.run @c.appear(item)
    @field.run_test
    
    assert_equal [:opacity=, [0.0]], item.calls.shift
    assert_equal [:visible=, [true]], item.calls.shift
    
    old_op = 0.0
    while true
      method, args = item.calls.shift
      break unless method == :opacity=
      assert_operator args.first, :>=, old_op
      old_op = args.first
    end
    
    assert_equal [], item.calls
  end
end
