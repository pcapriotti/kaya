# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'

class MultiView < KDE::TabWidget
  attr_reader :index
  include Observable
  include Enumerable
  
  def initialize(parent, movelist_stack, factories)
    super(parent)
    @movelist_stack = movelist_stack
    @factories = factories
    @views = []
    @index = -1
    tab_bar.visible = false
    tab_bar.tabs_closable = true
    on(:current_changed) {|i| self.index = i; fire :changed }
    tab_bar.on(:tab_close_requested) {|i| delete_at(i) }
  end
  
  def index=(value)
    if value >= 0 and value < size and value != @index
      @index = value
      self.current_index = value
      @movelist_stack.current_index = value
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
  
  def set_tab_text(i, name)
    puts "name = #{name}"
    super(i, name)
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
    table = @factories[:table].new(self)
    controller = @factories[:controller].new(table)
    movelist = @factories[:movelist].new(controller)
    
    v = View.new(table, controller, movelist)
    add(v, opts)
    v
  end
  
  def add(view, opts = { })
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
      v
    end
  end
  
  def size
    @views.size
  end
  
  def each(&blk)
    @views.each(&blk)
  end
end
