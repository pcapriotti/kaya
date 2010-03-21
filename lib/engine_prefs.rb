# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require 'plugins/loader'

class EngineData < KDE::Dialog
  include Observable
  
  def initialize(caption, parent, engine = nil)
    super(parent)
    
    @gui = KDE::autogui(:engine_data,
                        :caption => caption) do |g|
      g.layout(:type => :vertical) do |l|
        labelled(l, :name, KDE::i18n("&Name:")) do |h|
          h.line_edit(:name)
        end
        labelled(l, :type, KDE::i18n("&Type:")) do |h|
          h.combo_box(:type)
        end
        labelled(l, :games, KDE::i18n("&Games:")) do |h|
          h.widget(:games, :factory => Factory.new {|p| Game.new_combo(p) })
        end
        labelled(l, :path, KDE::i18n("&Path:")) do |h|
          h.url_requester(:path)
        end
        labelled(l, :args, KDE::i18n("&Arguments:")) do |h|
          h.line_edit(:args)
        end
        labelled(l, :workdir, KDE::i18n("&Work directory:")) do |h|
          h.url_requester(:workdir)
        end
      end
    end
    setGUI(@gui)
    
    loader = PluginLoader.new
    protocols = loader.get_all_matching(:engine).map do |klass|
      klass.data(:protocol)
    end.uniq
    protocols.each do |prot|
      type.add_item(prot)
    end

    if engine
      name.text = engine.name
      path.url = KDE::Url.new(engine.path) if engine.path
      args.text = engine.arguments if engine.arguments
      workdir.url = KDE::Url.new(engine.workdir) if engine.workdir
      current = (0...games.count).
        map{|i| games.item_data(i).toString }.
        index(engine.game.class.data(:id).to_s)
      games.current_index = current if current
      current = protocols.index(engine.protocol)
      type.current_index = current if current
    end
    
    name.set_focus
    
    on(:ok_clicked) do
      unless path.text.empty? or name.text.empty?
        protocol = type.current_text
        game = games.item_data(games.current_index).toString.to_sym
        fire :ok => {
          :name => name.text,
          :protocol => type.current_text,
          :arguments => args.text,
          :game => game,
          :path => path.url.path,
          :workdir => workdir.url.path }
      end
    end
  end
  
  def labelled(builder, name, label)
    builder.layout(:type => :horizontal) do |l|
      l.label(:text => label, :buddy => name)
      yield l
    end
  end
end

class EnginePrefs < KDE::Dialog
  def initialize(loader, parent)
    super(parent)
    @loader = loader
    
    @gui = KDE::autogui(:engine_prefs,
                        :caption => KDE.i18n("Configure Engines")) do |g|
      g.layout(:type => :horizontal) do |l|
        l.list(:list)
        l.layout(:type => :vertical) do |buttons|
          buttons.button(:add_engine,
                         :text => KDE.i18nc("engine", "&New..."),
                         :icon => 'list-add')
          buttons.button(:edit_engine,
                         :text => KDE.i18nc("engine", "&Edit..."),
                         :icon => 'configure')
          buttons.button(:delete_engine,
                         :text => KDE.i18nc("engine", "&Delete"),
                         :icon => 'list-remove')
          buttons.stretch
        end
      end
    end
    setGUI(@gui)

    list.model = Qt::StringListModel.new(
      @loader.map{|name, engine| name }, self)
    
    # save loader state
    @engines = { }
    @loader.each do |name, engine|
      @engines[name] = engine
    end
    
    add_engine.on(:clicked) { do_add_engine }
    edit_engine.on(:clicked) { do_edit_engine }
    delete_engine.on(:clicked) { do_delete_engine }

    on(:ok_clicked) do
      @loader.update_entries(@engines)
    end
  end
  
  def do_delete_engine
    index = current
    if index
      name = list.model.data(index, Qt::DisplayRole).toString
      list.model.remove_rows(index.row, 1)
      @engines.delete(name)
    end
  end
  
  def do_add_engine
    dialog = EngineData.new(KDE.i18n("New Engine"), self)    
    dialog.on(:ok) do |data|
      engine = @loader.engine.new(data)
      @engines[engine.name] = engine
      index = list.model.row_count
      list.model.insert_rows(index, 1)
      list.model.set_data(list.model.index(index, 0), 
                           Qt::Variant.new(engine.name),
                           Qt::DisplayRole)
    end
    dialog.exec
  end
  
  def do_edit_engine
    index = current
    if index
      old_name = list.model.data(index, Qt::DisplayRole).toString
      old_engine = @engines[old_name]
      dialog = EngineData.new(KDE.i18n("Edit Engine"), self, old_engine)
      dialog.on(:ok) do |data|
        engine = @loader.engine.new(data)
        if engine.name != old_name
          @engines.delete(old_name)
        end
        @engines[engine.name] = engine
        list.model.set_data(index, Qt::Variant.new(engine.name), Qt::DisplayRole)
      end
      dialog.exec
    end
  end
  
  def current
    indexes = list.selection_model.selection.indexes
    unless indexes.empty?
      indexes.first
    end
  end
end
