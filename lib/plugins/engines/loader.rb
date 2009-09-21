# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'plugins/plugin'
require 'factory'
require_bundle 'engines', 'find_exe'

class EngineLoader
  include Plugin
  include Enumerable
  
  class Entry < Factory
    AUTOLOADABLE_ENTRIES = {
      'gnuchess' => { :name => 'GNU Chess',
                      :game => :chess,
                      :protocol => 'XBoard',
                      :workdir => '/tmp' },
      'crafty' => { :name => 'Crafty',
                    :game => :chess,
                    :protocol => 'XBoard',
                    :workdir => '/tmp' },
      'gnushogi' => { :name => 'GNU Shogi',
                      :game => :shogi,
                      :protocol => 'GNUShogi',
                      :workdir => '/tmp' } }
    
    attr_accessor :name
    attr_accessor :game
    attr_accessor :protocol
    attr_accessor :workdir
    attr_accessor :path
    attr_accessor :arguments
  
    def initialize(data)
      loader = PluginLoader.new
      plugin = loader.get_all_matching(:engine).find do |e|
        e.data(:protocol) == data[:protocol]
      end
      fact = lambda do |color, match|
        plugin.new(@path, @name, color, match, 
                   :workdir => @workdir,
                   :args => @arguments)
      end
      super(&fact)
      
      @name = data[:name]
      @game = Game.get(data[:game])
      @protocol = data[:protocol]
      @arguments = data[:arguments]
      @workdir = data[:workdir]
      @path = data[:path]
    end
    
    def self.load(name, group)
      entries = group.entry_map
      entries['game'] ||= ''
      new :name => name,
          :game => entries['game'].to_sym,
          :path => entries['path'],
          :protocol => entries['protocol'],
          :arguments => entries['arguments'],
          :workdir => entries['workdir']
    end
    
    def save(group)
      group.write_entry('game', @game.class.data(:id).to_s)
      group.write_entry('path', @path.to_s)
      group.write_entry('protocol', @protocol.to_s)
      group.write_entry('arguments', @arguments.to_s)
      group.write_entry('workdir', @workdir.to_s)
    end
  end
  
  plugin :name => 'Default Engine Loader',
         :interface => :engine_loader

  def reload
    @entries = { }
    config = KDE::Global.config.group("Engines")
    autoload unless config.exists
    engine_groups = config.group_list
    engine_groups.each do |engine_group|
      entry = Entry.load(engine_group, config.group(engine_group))
      @entries[entry.name] = entry
    end
  end
  
  def autoload
    entries = { }
    Entry::AUTOLOADABLE_ENTRIES.each do |keyword, data|
      path = File.which(keyword)
      if path
        data = data.merge(:path => path)
        entries[data[:name]] = Entry.new(data)
      end
    end
    update_entries(entries) unless entries.empty?
  end
  
  def update_entries(entries)
    @entries = entries.dup
    
    config = KDE::Global.config.group("Engines")
    config.delete_group

    @entries.each do |name, engine|
      group = config.group(name)
      engine.save(group)
    end
    config.sync
  end
  
  def [](name)
    @entries[name]
  end

  def find_by_game(game)
    @entries.select do |name, e|
      e.game == game
    end
  end
  
  def each(&blk)
    @entries.each(&blk)
  end
  
  def size
    @entries.size
  end
  
  def engine
    Entry
  end
end
