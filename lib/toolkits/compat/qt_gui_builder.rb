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
        Qt::Menu.new(desc.opts[:name].to_s, window).tap do |menu|
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
        Qt::ToolBar.new(desc.opts[:name].to_s, parent)
      end
    end
  end
end
