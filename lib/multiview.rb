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
  
  CHANGED_SIG = 'currentChanged(int)'
  CLOSED_SIG = 'tabCloseRequested(int)'
  
  def initialize(parent, movelist_stack)
    super(parent)
    @movelist_stack = movelist_stack
    @views = []
    @index = -1
    tab_bar.visible = false
    tab_bar.tabs_closable = true
    on(CHANGED_SIG) {|i| self.index = i }
    tab_bar.on(CLOSED_SIG) {|i| delete_at(i) }
  end
  
  def index=(value)
    if value >= 0 and value < size and value != @index
      @index = value
      self.current_index = value
      @movelist_stack.current_index = value
    end
  end
  
  def current
    if @index != -1
      @views[@index]
    end
  end
  
  def add(view, opts = { })
    @views << view
    i = add_tab(view.main_widget, opts[:name] || "?")
    raise "[bug] inconsistent MultiView index #{size - 1}, expected #{i}" unless i == size - 1
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
