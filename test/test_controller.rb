require 'test/unit'
require 'controller'

class TestController < Test::Unit::TestCase
  def setup
    @board = mock('board')
    class << @board
      include Observable
    end
    @history = mock('history')
    @controller = Controller.new(@board, @history)
  end
  
  def test_on_new_move
    @history.expects(:add_move).once.with('state', 'move')
    @board.changed
    @board.notify_observers :new_move => { :state => 'state', :move => 'move' }
  end
  
  def test_back
    @history.expects(:back).returns(['state', 'move'])
    @board.expects(:back).with('state', 'move')
    @controller.on_back
  end
  
  def test_forward
    @history.expects(:forward).returns(['state', 'move'])
    @board.expects(:forward).with('state', 'move')
    @controller.on_forward
  end
end
