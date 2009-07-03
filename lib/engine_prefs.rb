# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'plugins/loader'

class EngineData < KDE::Dialog
  include Observable
  
  def initialize(caption, parent, engine = nil)
    super(parent)
    self.caption = caption
    self.buttons = KDE::Dialog::Ok | KDE::Dialog::Cancel
    
    page = Qt::Frame.new(self)
    layout = Qt::VBoxLayout.new(page)

    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE.i18n("&Name:"), page)
    tmp.add_widget(label)
    name = KDE::LineEdit.new(page)
    label.buddy = name
    tmp.add_widget(name)
    layout.add_layout(tmp)
    
    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE.i18n("&Type:"), page)
    tmp.add_widget(label)
    type = KDE::ComboBox.new(page)
    label.buddy = type
    loader = PluginLoader.new
    protocols = loader.get_all_matching(:engine).map do |klass|
      klass.data(:protocol)
    end.uniq
    protocols.each do |prot|
      type.add_item(prot)
    end

    tmp.add_widget(type)
    layout.add_layout(tmp)
    
    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE.i18n("&Game:"), page)
    tmp.add_widget(label)
    games = Game.new_combo(page)

    label.buddy = games
    tmp.add_widget(games)
    layout.add_layout(tmp)
    
    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE.i18n("&Path:"), page)
    tmp.add_widget(label)
    path = KDE::UrlRequester.new(page)
    label.buddy = path
    tmp.add_widget(path)
    layout.add_layout(tmp)
    
    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE.i18n("&Work directory:"), page)
    tmp.add_widget(label)
    workdir = KDE::UrlRequester.new(page)
    label.buddy = workdir
    tmp.add_widget(workdir)
    layout.add_layout(tmp)

    if engine
      name.text = engine.name
      path.url = KDE::Url.new(engine.path)
      workdir.url = KDE::Url.new(engine.workdir)
      current = (0...games.count).
        map{|i| games.item_data(i).toString }.
        index(engine.game.class.data(:id).to_s)
      games.current_index = current if current
      current = protocols.index(engine.protocol)
      type.current_index = current if current
    end

    self.main_widget = page
    
    name.set_focus
    
    on(:okClicked) do
      unless path.text.empty? or name.text.empty?
        protocol = type.current_text
        game = games.item_data(games.current_index).toString.to_sym
        fire :ok => {
          :name => name.text,
          :protocol => type.current_text,
          :game => game,
          :path => path.url.path,
          :workdir => workdir.url.path }
      end
    end
  end
end

class EnginePrefs < KDE::Dialog
  def initialize(loader, parent)
    super(parent)
    @loader = loader
    self.caption = KDE.i18n("Configure Engines")
    self.buttons = KDE::Dialog::Ok | KDE::Dialog::Cancel
    widget = Qt::Frame.new(self)
    
    layout = Qt::HBoxLayout.new(widget)
    
    @list = Qt::ListView.new(widget)
    @list.model = Qt::StringListModel.new(
      @loader.map{|name, engine| name }, self)
    
    # save loader state
    @engines = { }
    @loader.each do |name, engine|
      @engines[name] = engine
    end
    
    layout.add_widget(@list)
    
    buttons = Qt::VBoxLayout.new
    @add_engine = KDE::PushButton.new(
      KDE::Icon.new('list-add'), KDE.i18n("&New..."), widget)
    buttons.add_widget(@add_engine)
    @edit_engine = KDE::PushButton.new(
      KDE::Icon.new('configure'), KDE.i18n("&Edit..."), widget)
    buttons.add_widget(@edit_engine)
    @delete_engine = KDE::PushButton.new(
      KDE::Icon.new('list-remove'), KDE.i18n("&Delete"), widget)
    buttons.add_widget(@delete_engine)
    
    buttons.add_stretch
    layout.add_layout(buttons)

    @add_engine.on(:pressed) { add_engine }
    @edit_engine.on(:pressed) { edit_engine }
    @delete_engine.on(:pressed) { delete_engine }
#     @list.on('itemDoubleClicked(QListWidgetItem*)') { edit_engine }

    self.main_widget = widget

    on(:okClicked) do
      @loader.update_entries(@engines)
    end
  end
  
  def delete_engine
    index = current
    if index
      @list.model.remove_rows(index.row, 1)
    end
  end
  
  def add_engine
    dialog = EngineData.new(KDE.i18n("New Engine"), self)
    dialog.observe(:ok) do |data|
      engine = @loader.engine.new(data)
      @engines[engine.name] = engine
      index = @list.model.row_count
      @list.model.insert_rows(index, 1)
      @list.model.set_data(@list.model.index(index, 0), 
                           engine.name,
                           Qt::DisplayRole)
    end
    dialog.exec
  end
  
  def edit_engine
    index = current
    if index
      old_name = @list.model.data(index, Qt::DisplayRole).toString
      old_engine = @engines[old_name]
      dialog = EngineData.new(KDE.i18n("Edit Engine"), self, old_engine)
      dialog.observe(:ok) do |data|
        engine = @loader.engine.new(data)
        if engine.name != old_name
          @engines.delete(old_name)
        end
        @engines[engine.name] = engine
        @list.model.set_data(index, engine.name, Qt::DisplayRole)
      end
      dialog.exec
    end
  end
  
  def current
    indexes = @list.selection_model.selection.indexes
    unless indexes.empty?
      indexes.first
    end
  end
end
