require 'test/unit'
require 'observer_utils'

class TestObserverUtils < Test::Unit::TestCase
  class FakeObservable
    include Observable
  end
  
  def setup
    @object = FakeObservable.new
  end
  
  def test_simple_observer
    ok = false
    @object.observe('something') { ok = true }
    @object.changed
    @object.notify_observers :something => nil
    assert ok
  end
  
  def test_observer
    obs = Object.new
    class << obs
      include Observer
      attr_reader :arg
      
      def on_something(arg)
        @arg = arg
      end
    end
    
    @object.add_observer(obs)
    @object.changed
    @object.notify_observers :something => 37
    
    assert_equal 37, obs.arg
  end
  
  def test_multiple_observer
    obs = Object.new
    class << obs
      include Observer
      attr_reader :arg1, :arg2
      
      def on_whatever(arg1)
        @arg1 = arg1
      end
      
      def on_something(arg2)
        @arg2 = arg2
      end
    end
    
    @object.add_observer(obs)
    @object.changed
    @object.notify_observers :something => 2, :whatever => 1, :nothing => 3
    
    assert_equal 1, obs.arg1
    assert_equal 2, obs.arg2
  end
end
