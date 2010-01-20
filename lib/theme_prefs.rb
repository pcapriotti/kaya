# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'

class ThemePrefs < KDE::Dialog
  def initialize(loader, parent)
    super(parent)

    @loader = loader
    widget = Qt::Frame.new(self)
    layout = Qt::HBoxLayout.new(widget)
    @tabs = Qt::TabWidget.new(widget)
    layout.add_widget(@tabs)
    @games = Qt::ListWidget.new(nil)
    @categories = Qt::ListWidget.new(nil)
    @tabs.add_tab(@games, KDE::i18n('&Games'))
    @tabs.add_tab(@categories, KDE::i18n('&Categories'))
    
    info_layout = Qt::VBoxLayout.new
    layout.add_layout(info_layout)

    @pieces = new_labelled(KDE::ComboBox, '&Pieces:', widget, info_layout)
    @board = new_labelled(KDE::ComboBox, '&Board:', widget, info_layout)
    @layout = new_labelled(KDE::ComboBox, '&Layout:', widget, info_layout)
    @clock = new_labelled(KDE::ComboBox, '&Clock:', widget, info_layout)
    info_layout.add_stretch
    
    self.main_widget = widget
    
    fill_games
    fill_categories
  end
  
  def new_labelled(widget_factory, label, parent, layout)
    label = Qt::Label.new(label, parent)
    layout.add_widget(label)
    widget = widget_factory.new(parent)
    label.buddy = widget
    layout.add_widget(widget)
    widget
  end
  
  private
  
  def fill_games
    Game.each do |name, game|
      @games.add_item(game.class.data(:name))
    end
  end

  def fill_categories
    Game.categories.each do |category|
      @categories.add_item(category)
    end
  end
end
