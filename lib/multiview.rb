# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'

class MultiView < KDE::TabWidget
  attr_reader :index
  attr_accessor :clean
  
  include Observable
  include Observer
  include Enumerable
  
  def initialize(parent, movelist_stack, factories)
    super(parent)
    @movelist_stack = movelist_stack
    @factories = factories
    @views = []
    @index = -1
    tab_bar.visible = false
    tab_bar.tabs_closable = true
    on(:current_changed, ["int"]) {|i| self.index = i; fire :changed }
    tab_bar.on(:tab_close_requested) {|i| delete_at(i) }
  end
  
  def index=(value)
    if value >= 0 and value < size and value != @index
      @index = value
      self.current_index = value
      @movelist_stack.current_index = value
      on_activity(current, false)
    end
  end
  
  def activate(user, name = nil)
    @views.each_with_index do |view, i|
      if user == view.controller
        self.index = i
        set_tab_text(i, name) if name
        break
      end
    end
  end
  
  def find
    @views.each_with_index do |view, i|
      return i if yield view
    end
    nil
  end
  
  def current
    if @index != -1
      @views[@index]
    end
  end
  
  def current_name
    if @index != -1
      tab_text(@index)
    end
  end
  
  def create(opts =  { })
    if @clean and not opts[:force]
      @clean = false
      if opts[:name]
        set_tab_text(index, opts[:name])
        fire :changed
      end
      current
    else    
      @clean = false
      table = @factories[:table].new(self)
      controller = @factories[:controller].new(table)
      movelist = @factories[:movelist].new(controller)
      
      v = View.new(table, controller, movelist)
      add(v, opts)
      v
    end
  end
  
  def add(view, opts = { })
    view.add_observer(self)
    @views << view
    i = add_tab(view.main_widget, opts[:name] || "?")
    unless i == size - 1
      raise "[bug] inconsistent MultiView index #{size - 1}, expected #{i}"
    end
    @movelist_stack.insert_widget(i, view.movelist)
    if opts[:activate] || index == -1
      self.index = i
    end
    tab_bar.visible = size > 1
    i
  end
  
  def delete_at(index)
    raise "Cannot delete last view" if size <= 1
    if index >= 0 and index < size
      self.index -= 1 if index <= @index
      removeTab(index)
      v = @views.delete_at(index)
      @movelist_stack.remove_widget(v.movelist)
      tab_bar.visible = size > 1
      v.controller.close
      v.close
      v.delete_observer(self)
      v
    end
  end
  
  def size
    @views.size
  end
  
  def each(&blk)
    @views.each(&blk)
  end
  
  def on_activity(view, value = true)
    i = find { |v| v == view }
    return unless i
    @@base_color ||= tab_bar.tab_text_color(i)
    
    if i != @index && value
      tab_bar.set_tab_text_color(i, KDE::active_color)
    else
      tab_bar.set_tab_text_color(i, @@base_color)
    end
  end
  
  def on_dirty(view, value = true)
    @clean = false
  end
end
