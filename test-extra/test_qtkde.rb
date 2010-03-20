# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'toolkits/qt'
require 'toolkits/compat/qtkde'

class TestQtKDECompatibility < Test::Unit::TestCase
  def test_empty_descriptor
    desc = Qt::gui(:desc_test)
    assert_equal '(gui {:gui_name=>:desc_test})', desc.to_sexp
  end
  
  def test_menu_bar_descriptor
    desc = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :new
          m.action :open
          m.separator
          m.action :quit
        end
      end
    end
    
    sexp = '(gui {:gui_name=>:desc_test} ' +
              '(menu_bar {} ' +
                '(menu {:name=>:file} ' +
                  '(action {:name=>:new}) ' +
                  '(action {:name=>:open}) ' +
                  '(separator {}) ' +
                  '(action {:name=>:quit}))))'
    assert_equal sexp, desc.to_sexp
  end

  def test_merge_equal
    desc = Qt::gui(:desc_test)
    desc2 = Qt::gui(:desc_test)
    
    desc.merge!(desc2)
    sexp = '(gui {:gui_name=>:desc_test})'
    assert_equal sexp, desc.to_sexp
  end
  
  def test_merge_children
    desc = Qt::gui(:desc_test) do |g|
      g.item :a
      g.item :b
    end
    
    desc2 = Qt::gui(:desc_test) do |g|
      g.item :c
      g.item :d
    end
    
    desc.merge!(desc2)
    sexp = '(gui {:gui_name=>:desc_test} ' +
              '(item {:name=>:a}) ' +
              '(item {:name=>:b}) ' +
              '(item {:name=>:c}) ' +
              '(item {:name=>:d}))'
    assert_equal sexp, desc.to_sexp
  end
  
  def test_merge_recursive
    desc = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.item :a
        mb.item :b
      end
    end
    
    desc2 = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.item :c
        mb.item :d
      end
    end
    
    desc.merge!(desc2)
    sexp = '(gui {:gui_name=>:desc_test} ' +
              '(menu_bar {} ' + 
                '(item {:name=>:a}) ' +
                '(item {:name=>:b}) ' +
                '(item {:name=>:c}) ' +
                '(item {:name=>:d})))'
    assert_equal sexp, desc.to_sexp
  end
  
  def test_simple_merge
    desc = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :new
          m.action :open
          m.separator
          m.action :quit
        end
      end
    end

    desc2 = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :save
        end
        mb.menu(:edit) do |m|
          m.action :undo
        end
      end
      g.tool_bar(:main_tool_bar)
    end

    desc.merge!(desc2)
    sexp = '(gui {:gui_name=>:desc_test} ' +
              '(menu_bar {} ' +
                '(menu {:name=>:file} ' +
                  '(action {:name=>:new}) ' +
                  '(action {:name=>:open}) ' +
                  '(separator {}) ' +
                  '(action {:name=>:quit}) ' +
                  '(action {:name=>:save})) ' +
                '(menu {:name=>:edit} ' +
                  '(action {:name=>:undo}))) ' +
              '(tool_bar {:name=>:main_tool_bar}))'
    
    assert_equal sexp, desc.to_sexp
  end
  
  def test_merge_partial
    desc = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :open
        end
        mb.menu(:edit) do |m|
          m.action :undo
        end
      end
    end
    
    desc2 = Qt::gui(:desc_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:edit) do |m|
          m.action :redo
        end
        mb.menu(:game) do |m|
          m.action :forward
          m.action :back
        end
      end
    end
    
    desc.merge!(desc2)
    sexp = '(gui {:gui_name=>:desc_test} ' +
              '(menu_bar {} ' +
                '(menu {:name=>:file} ' +
                  '(action {:name=>:open})) ' +
                '(menu {:name=>:edit} ' +
                  '(action {:name=>:undo}) ' +
                  '(action {:name=>:redo})) ' +
                '(menu {:name=>:game} ' +
                  '(action {:name=>:forward}) ' +
                  '(action {:name=>:back}))))'
    assert_equal sexp, desc.to_sexp
  end
end
