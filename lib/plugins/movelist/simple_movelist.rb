# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require 'plugins/plugin'
require 'observer_utils'

class SimpleMoveList < Qt::ListView
  include Plugin
  include Observer
  
  plugin :name => 'Simple Move List',
         :interface => :movelist
         
  class LinearHistoryModel < Qt::StringListModel
    include Observer
    include Observable
    
    def initialize(match)
      super([])
      @history = match.history
      @serializer = match.game.serializer.new(:compact)
      @numbering_style = match.game.numbering_style
      @history.add_observer(self)
      
      insert_rows(0, @history.size)
      (0...@history.size).each do |i|
        update_row(i)
      end
    end
    
    def on_new_move(data)
      old_count = rowCount
      if @history.size > old_count
        insert_rows(old_count, @history.size - old_count)
      else
        remove_rows(@history.size, old_count - @history.size)
      end
      (data[:old_current] + 1...rowCount).each do |i|
        update_row(i)
      end
      on_current_changed
    end
    
    def on_truncate(index)
      remove_rows(index + 1, rowCount - index - 1)
    end

    def on_current_changed
      fire :change_current => index(@history.current, 0)
    end
    
    def on_force_update
      update_row(@history.current)
    end
    
    def move(i)
      if i == 0
        KDE::i18n('Mainline')
      else
        state = @history[i - 1].state
        move = @history[i].move
        if move
          @history[i].text ||= @serializer.serialize(move, state)
        else
          @history[i].text ||= "???"
        end
        
        @numbering_style.format_move(i, @history[i].text)
      end
    end
    
    def update_row(i)
      set_data(index(i, 0), Qt::Variant.new(move(i)), Qt::DisplayRole)
    end
    
    def flags(index)
      if index.isValid
        Qt::ItemIsSelectable | Qt::ItemIsEnabled
      else
        Qt::NoItemFlags
      end
    end
  end
  
  def initialize(controller, opts = {})
    super(controller.table)
    @controller = controller
    self.font = opts[:font] if opts[:font]
    
    @controller.table.add_observer(self)
  end
  
  def on_reset(match)
    if match.game.respond_to?(:serializer)
      self.model = LinearHistoryModel.new(match)
      model.on(:change_current) do |current|
        select(current)
      end
      selection_model.on(:selection_changed) do |selected, deselected|
        index = selected.indexes.first
        match.go_to(nil, index.row) if index
      end
      # select last item
      select(model.index(model.row_count - 1, 0))
    else
      self.model = nil
    end
  end
  
  def select(index)
    selection_model.select(index, 
      Qt::ItemSelectionModel::ClearAndSelect)
    scroll_to(index)    
  end
end

