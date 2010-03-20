# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'toolkits/kde'
require 'rexml/document'

class TestGuiBuilder < Test::Unit::TestCase
  def test_empty_gui
    xml = REXML::Document.new(KDE::gui(:gui_test))
    assert_equal "<!DOCTYPE kpartgui SYSTEM \"kpartgui.dtd\">", xml.doctype.to_s
    assert_equal "gui", xml.root.name
    assert_equal "2", xml.root.attributes["version"]
    assert_equal "gui_test", xml.root.attributes["name"]
  end
  
  def test_menu_bar
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar
    end
    xml = REXML::Document.new(gui)
    
    assert_equal "gui", xml.root.name
    assert xml.root.elements["MenuBar"]
  end
  
  def test_empty_menus
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file)
      end
    end
    xml = REXML::Document.new(gui)
    
    assert xml.elements["gui/MenuBar/Menu"]
    assert_equal "file", xml.elements["gui/MenuBar/Menu"].attributes["name"]
  end
  
  def test_menu_with_actions
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :open
          m.action :save
          m.action :exit
        end
        mb.menu(:edit, :text => "Edit") do |m|
          m.action :cut
          m.action :copy
          m.action :paste
        end
      end
    end
    xml = REXML::Document.new(gui)
    
    file_menu = xml.elements["gui/MenuBar/Menu[1]"]
    assert file_menu
    assert_equal "file", file_menu.attributes["name"]
    assert_equal ["open", "save", "exit"], 
                 file_menu.to_enum(:each_element, "Action").
                   map{|x| x.attributes["name"] }
    
    edit_menu = xml.elements["gui/MenuBar/Menu[2]"]
    assert edit_menu
    assert_equal "Edit", edit_menu.elements["text"].text
    assert_equal "edit", edit_menu.attributes["name"]
    assert_equal ["cut", "copy", "paste"], 
                 edit_menu.to_enum(:each_element, "Action").
                   map{|x| x.attributes["name"] }
  end
  
  def test_menu_with_separators
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :open
          m.action :save
          m.separator
          m.action :exit
        end
      end
    end
    xml = REXML::Document.new(gui)
    
    menu = xml.elements["gui/MenuBar/Menu"]
    assert menu
    assert_equal "file", menu.attributes["name"]
    assert menu.elements["Separator"]
  end
  
  def test_toolbar
    gui = KDE::gui(:gui_test) do |g|
      g.tool_bar(:file, :text => "File") do |tb|
        tb.action :open
        tb.action :save
        tb.action :exit
      end
    end
    xml = REXML::Document.new(gui)
    
    tool_bar = xml.elements["gui/ToolBar"]
    assert tool_bar
    assert_equal "file", tool_bar.attributes["name"]
    assert_equal "File", tool_bar.elements["text"].text
    assert_equal ["open", "save", "exit"], 
                 tool_bar.to_enum(:each_element, "Action").
                   map{|x| x.attributes["name"] }
  end
  
  def test_action_list
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar do |mb|
        mb.menu("file") do |m|
          m.action :open
          m.action :save
          m.separator
          m.action_list :recent_files
          m.action :exit
        end
      end
    end
    xml = REXML::Document.new(gui)
    
    menu = xml.elements["gui/MenuBar/Menu"]
    assert menu
    assert "recent_files", menu.elements["ActionList"].attributes["name"]
  end
  
  def test_group
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar do |mb|
        mb.menu("file") do |m|
          m.action :open
          m.action :save
          m.separator
          m.group :extension
          m.action :exit
        end
      end
    end
    xml = REXML::Document.new(gui)
    
    menu = xml.elements["gui/MenuBar/Menu"]
    assert menu
    assert "extension", menu.elements["DefineGroup"].attributes["name"]    
  end
  
  def test_group_actions
    gui = KDE::gui(:gui_test) do |g|
      g.menu_bar do |mb|
        mb.menu(:file) do |m|
          m.action :open
          m.group(:extension) do |g|
            g.action :connect
            g.action :disconnect
          end
          m.action :quit
        end
      end
    end
    xml = REXML::Document.new(gui)
    
    menu = xml.elements["gui/MenuBar/Menu"]
    assert menu
    assert_nil menu.elements["DefineGroup"]
    assert_equal "extension", menu.elements["Action[@name='connect']"].
                              attributes["group"]
  end
end
