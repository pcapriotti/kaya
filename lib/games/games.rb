# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'factory'
require 'plugins/loader'
require 'qtutils'

class Game
  GAMES = { }
  LOADER = PluginLoader.new

  def self.load_all(directory = nil)
    klasses = { }
    LOADER.get_all_matching(:game).each do |game|
      klasses[game.data(:id)] = game
    end
    
    klasses.values.each {|klass| register_game(klasses, klass) }
  end

  def self.dummy
    # dummy is chess for the moment
    get(:chess)
  end

  def self.get(name)
    GAMES[name]
  end
  
  def self.each(&blk)
    GAMES.each(&blk)
  end

  def self.new_combo(parent)
    KDE::ComboBox.new(parent) do
      self.editable = false
      GAMES.map do |id, g|
        [g.class.data(:name), id.to_s]
      end.sort.each do |name, id|
        add_item(name, id)
      end
    end
  end
  
  private
  
  def self.register_game(klasses, klass)
    unless Game.get(klass.data(:id))
      # register dependencies
      (klass.data(:depends) || []).each do |dep|
        depklass = klasses[dep] or
          raise "Invalid dependency #{dep} for game #{klass.plugin_name}"
        register_game(klasses, depklass)
        klass.instance_eval do
          define_method(dep) { Game.get(dep) }
        end
      end
      # register superclass
      if klasses.values.include?(klass.superclass)
        register_game(klasses, klass.superclass)
      end
      GAMES[klass.data(:id)] = klass.new
    end
  end
end

