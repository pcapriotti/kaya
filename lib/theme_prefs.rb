# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'

class ThemePrefs < KDE::Dialog
  def initialize(loader, theme_loader, parent)
    super(parent)

    @loader = loader
    @theme_loader = theme_loader
    widget = Qt::Frame.new(self)
    layout = Qt::HBoxLayout.new(widget)
    @tabs = Qt::TabWidget.new(widget)
    layout.add_widget(@tabs)
    @lists = {
      :game => Game.new_list(nil),
      :category => Qt::ListWidget.from_a(nil, Game.categories)
    }
    @tabs.add_tab(@lists[:game], KDE::i18n('&Games'))
    @tabs.add_tab(@lists[:category], KDE::i18n('&Categories'))
    @tabs.current_index = 0
    @lists[:game].current_index = 0
    
    info_layout = Qt::VBoxLayout.new
    layout.add_layout(info_layout)

    @combos = {
      :pieces => new_labelled(combo_factory(:pieces), '&Pieces:', widget, info_layout),
      :board => new_labelled(combo_factory(:board), '&Board:', widget, info_layout),
      :layout => new_labelled(combo_factory(:layout), '&Layout:', widget, info_layout),
      :clock => new_labelled(combo_factory(:clock), '&Clock:', widget, info_layout)
    }
    
    info_layout.add_stretch
    
    self.main_widget = widget

    update
    @tabs.on('currentChanged(int)') { update }
    @lists.each {|type, list| list.on(:itemSelectionChanged) { update(type) } }
    on(:okClicked) { @theme_loader.save }
  end
  
  private
  
  def current_type
    if @tabs.current_widget == @lists[:game]
      :game
    else
      :category
    end
  end
  
  def item_name(type, data)
    type == :game ? data.class.data(:id) : data
  end
  
  def new_labelled(widget_factory, label, parent, layout)
    label = Qt::Label.new(label, parent)
    layout.add_widget(label)
    widget = widget_factory.new(parent)
    label.buddy = widget
    layout.add_widget(widget)
    widget
  end
  
  def combo_factory(name)
    Factory.new do |parent|
      themes = @loader.get_all_matching(name).map do |plugin|
        [plugin.plugin_name, plugin]
      end
      themes = [['', nil]] + themes
      KDE::ComboBox.from_a(parent, themes).tap do |combo|
        combo.on('currentIndexChanged(int)') do
          type = current_type
          item = @lists[type].current_item
          @theme_loader.set(type, item_name(type, item.get), 
                            name, combo.current_item.get) if item
        end
      end
    end
  end

  def update(type = nil)
    type ||= current_type
    item = @lists[type].current_item
    
    @combos.each do |component, combo|
      combo.enabled = !!item
    end
    
    if item
      theme = @theme_loader.load_spec(type => item.get)
      @combos.each do |component, combo|
        klass = theme[component]
        combo.select_item do |data|
          data == klass
        end
      end
    end
  end
end
