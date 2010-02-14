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
        [g.class.plugin_name, id.to_s]
      end.sort.each do |name, id|
        add_item(name, Qt::Variant.new(id))
      end
    end
  end

  def self.new_list(parent)
    games = GAMES.map do |id, g|
      [g.class.plugin_name, g]
    end.sort
    Qt::ListWidget.from_a(parent, games)
  end
  
  def self.categories
    @@categories ||= to_enum(:each).map {|name, game| game.class.data(:category) }.uniq.sort
    @@categories
  end
  
  private
  
  class GameListWidgetItem < Qt::ListWidgetItem
    GAME_ID_ROLE = Qt::UserRole

    def initialize(name, id, list)
      super(name, list)
      set_data(GAME_ID_ROLE, Qt::Variant.new(id))
    end

    def game
      id = data(GAME_ID_ROLE).toString.to_sym
      Game.get(id)
    end
  end

  class GameProxy
    def initialize(game, context)
      @game = game
      @context = context
    end
    
    def method_missing(m, *args)
      result = @game.__send__(m, *args)
      if result.respond_to? :__bind__
        result.__bind__(@context)
      else
        result
      end
    end
  end
  
  module GameExtras
    module ClassMethods
      def _load(source)
        instance
      end
      
      def instance
        Game.get(data(:id))
      end
    end
    
    def _dump(limit = -1)
      self.class.data(:id).to_s
    end
    
    def self.included(base)
      base.extend ClassMethods
    end
  end
  
  def self.register_game(klasses, klass)
    unless Game.get(klass.data(:id))
      # register dependencies
      (klass.data(:depends) || []).each do |dep|
        depklass = klasses[dep] or
          raise "Invalid dependency #{dep} for game #{klass.plugin_name}"
        register_game(klasses, depklass)
        dep_game = Game.get(dep)
        klass.instance_eval do
          define_method(dep) { GameProxy.new(dep_game, self) }
        end
      end
      # register superclass
      if klasses.values.include?(klass.superclass)
        register_game(klasses, klass.superclass)
      end
      
      # add extra methods
      klass.instance_eval { include GameExtras }
      
      GAMES[klass.data(:id)] = klass.new
    end
  end
end

