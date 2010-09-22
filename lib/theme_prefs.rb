# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

class ThemePrefs < KDE::Dialog
  include Observable
  
  def initialize(loader, theme_loader, parent)
    super(parent)
    
    @loader = loader
    @theme_loader = theme_loader
    @combos = [
      [:pieces, KDE::i18n("&Pieces:")],
      [:board, KDE::i18n("&Board:")],
      [:layout, KDE::i18n("&Layout:")],
      [:clock, KDE::i18n("&Clock:")]]
    @lists = {
      :game => Factory.new {|p| Game.new_list(p) },
      :category => Factory.new {|p| Qt::ListWidget.from_a(p, Game.categories) }
    }
    
    @gui = KDE::autogui(:themes, 
                        :caption => KDE::i18n("Configure themes")) do |g|
      g.layout(:type => :horizontal) do |l|
        l.tab_widget(:tabs) do |tabs|
          tabs.tab(:text => KDE::i18n("&Games")) do |t|
            t.widget(:game, :factory => @lists[:game])
          end
          tabs.tab(:text => KDE::i18n("&Categories")) do |t|
            t.widget(:category, :factory => @lists[:category])
          end
        end
        l.layout(:type => :vertical) do |info|
          @combos.each do |name, text|
            info.label(:text => text, :buddy => name)
            info.widget(name, :factory => combo_factory(name))
          end
          info.stretch
        end
      end
    end
    setGUI(@gui)
    
    tabs.current_index = 0
    game.current_index = 0
    
    update
    tabs.on(:current_changed) { update }
    @lists.each_key {|name| send(name).on(:item_selection_changed) { update(name) } }
    on(:ok_clicked) do
      @theme_loader.save
      fire :ok
    end
  end
  
  private
  
  def current_type
    if tabs.current_widget == game
      :game
    else
      :category
    end
  end
  
  def item_name(type, data)
    type == :game ? data.class.data(:id) : data
  end
  
  def combo_factory(name)
    Factory.new do |parent|
      themes = @loader.get_all_matching(name).map do |plugin|
        [plugin.plugin_name, plugin]
      end
      themes = [['', nil]] + themes
      KDE::ComboBox.from_a(parent, themes).tap do |combo|
        combo.on(:current_index_changed, ["int"]) do |i|
          type = current_type
          item = send(type).current_item
          @theme_loader.set(type, item_name(type, item.get), 
                            name, combo.current_item.get) if item
        end
      end
    end
  end

  def update(type = nil)
    type ||= current_type
    item = send(type).current_item
    
    @combos.each do |component, _|
      send(component).enabled = !!item
    end
    
    if item
      theme = @theme_loader.load_spec(type => item.get)
      @combos.each do |component, _|
        klass = theme[component]
        send(component).select_item do |data|
          data == klass
        end
      end
    end
  end
end
