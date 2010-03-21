# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Qt
  module GuiBuilder    
    def self.build(window, gui)
      Gui.new.build(window, nil, gui)
    end
    
    def build(window, parent, desc)
      element = create_element(window, parent, desc)
      desc.children.each do |child|
        b = builder(child.name).new
        b.build(window, element, child)
      end
      element
    end
    
    def setup_widget(widget, parent, layout, desc)
      layout.add_widget(widget)
      if desc.opts[:name]
        parent.add_accessor(desc.opts[:name], widget)
      end        
    end
    
    def builder(name)
      GuiBuilder.const_get(name.to_s.capitalize.camelize)
    end
    
    class Gui
      include GuiBuilder
      def create_element(window, parent, desc)
        window
      end
    end
    
    class MenuBar
      include GuiBuilder
      
      def create_element(window, parent, desc)
        window.menu_bar
      end
    end
    
    class Menu
      include GuiBuilder
      
      def create_element(window, parent, desc)
        Qt::Menu.new(desc.opts[:text].to_s, window).tap do |menu|
          parent.add_menu(menu)
        end
      end
    end
    
    class Action
      include GuiBuilder
      
      def create_element(window, parent, desc)
        action = window.action_collection[desc.opts[:name]]
        if action
          parent.add_action(action)
        end
        action
      end
    end
    
    class Separator
      include GuiBuilder
      
      def create_element(window, parent, desc)
        parent.add_separator
      end
    end
    
    class Group
      include GuiBuilder
      
      def create_element(window, parent, desc)
        parent
      end
    end
    
    class ActionList
      include GuiBuilder
      
      def create_element(window, parent, desc)
        parent
      end
    end
    
    class ToolBar
      include GuiBuilder
      
      def create_element(window, parent, desc)
        Qt::ToolBar.new(desc.opts[:text].to_s, parent).tap do |tb|
          tb.object_name = desc.opts[:name].to_s
          parent.add_tool_bar(Qt::TopToolBarArea, tb)
        end
      end
    end
    
    class Layout
      include GuiBuilder
      
      def create_element(window, parent, desc)
        factory = if desc.opts[:type] == :horizontal
          Qt::HBoxLayout
        else
          Qt::VBoxLayout
        end
        factory.new.tap do |layout|
          layout.margin = desc.opts[:margin] if desc.opts[:margin]
          parent.add_layout(layout)
        end
      end
    end
    
    class Stretch
      include GuiBuilder
      
      def create_element(window, parent, desc)
        parent.add_stretch
      end
    end
    
    class Label
      include GuiBuilder
      
      def create_element(window, parent, desc)
        Qt::Label.new(desc.opts[:text].to_s, window).tap do |label|
          setup_widget(label, window, parent, desc)
          if desc.opts[:buddy]
            window.buddies[label] = desc.opts[:buddy]
          end
        end
      end
    end
    
    class TabWidget
      include GuiBuilder
      
      def create_element(window, parent, desc)
        KDE::TabWidget.new(window).tap do |widget|
          setup_widget(widget, window, parent, desc)
          widget.owner = window.owner
        end
      end
    end
    
    class Widget
      include GuiBuilder
      
      def create_element(window, parent, desc)
        factory(desc).new(window).tap do |widget|
          setup_widget(widget, window, parent, desc)
        end
      end
      
      def factory(desc)
        desc.opts[:factory]
      end
    end
    
    class Tab
      include GuiBuilder
      
      class Helper
        def initialize(parent, text)
          @parent = parent
          @text = text
        end
        
        def add_widget(widget)
          @parent.add_tab(widget, @text)
        end
      end
      
      def build(window, parent, desc)
        desc.children.each do |child|
          b = builder(child.name).new
          b.build(parent, Helper.new(parent, desc.opts[:text]), child)
        end
      end
    end
    
    class UrlRequester < Widget
      def factory(desc)
        KDE::UrlRequester
      end
    end

    class LineEdit < Widget
      def factory(desc)
        Qt::LineEdit
      end
    end
    
    class ComboBox < Widget
      def factory(desc)
        KDE::ComboBox
      end
    end
    
    class List < Widget
      def factory(desc)
        Qt::ListView
      end
    end
    
    class CheckBox < Widget
      def factory(desc)
        Factory.new do |parent|
          Qt::CheckBox.new(parent).tap do |check|
            check.text = desc.opts[:text].to_s
            check.checked = desc.opts[:checked]
          end
        end
      end
    end
    
    class Button < Widget
      def factory(desc)
        Factory.new do |parent|
          KDE::PushButton.new(KDE::Icon.from_theme(desc.opts[:icon]), 
                              desc.opts[:text], parent)
        end
      end
    end
  end
end
