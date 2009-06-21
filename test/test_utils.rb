require 'test/unit'
require 'rubygems'
require 'mocha'
require 'qtutils'

class TestQtUtils < Test::Unit::TestCase
  def test_painter_bracket
    p = Qt::Painter.new
    p.expects(:fill_rect).once
    p.expects(:end).once
    
    p.paint do |painter|
      painter.fill_rect
    end
  end
  
  def test_detect_index
    alphabet = ('a'..'z')
    h = alphabet.detect_index {|l| "hello"[0, 1] == l }
    
    assert_equal 7, h
    
    result = alphabet.detect_index {|l| 0 == 1 }
    assert_nil result
  end
end