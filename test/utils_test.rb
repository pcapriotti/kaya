require 'test/unit'
require 'rubygems'
require 'mocha'
require 'qtutils'

class QtUtilsTest < Test::Unit::TestCase
  def test_painter_bracket
    p = Qt::Painter.new
    p.expects(:fill_rect).once
    p.expects(:end).once
    
    p.paint do |painter|
      painter.fill_rect
    end
  end
end