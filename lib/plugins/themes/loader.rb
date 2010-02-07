# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require_bundle 'themes', 'theme'

class ThemeLoader
  include Plugin
  
  plugin :name => 'Default Theme Loader',
         :interface => :theme_loader
  
  def initialize
    @fallback_spec = { :pieces => CelticPieces,
                       :board => XBoardBackground,
                       :clock => XBoardClock,
                       :layout => XBoardLayout }
    config = KDE::Global.config.group('Themes')
    if config.exists
      @themes_cat = { }
      config.group("Categories").each_group do |cat|
        @themes_cat[cat.name] = cat.entry_map.maph {|k,v| [k.to_sym, eval(v) ] }
      end
      @themes = { }
      config.group("Games").each_group do |game|
        @themes[game.name] = game.entry_map.maph {|k,v| [k.to_sym, eval(v) ] }
      end
    else
      # default theme configuration
      @themes_cat = {
        'Chess' => { :pieces => CelticPieces,
                    :board => XBoardBackground,
                    :clock => XBoardClock,
                    :layout => XBoardLayout },
        'Shogi' => { :pieces => ShogiPieces,
                    :board => ShogibanBackground,
                    :clock => BubblesClock,
                    :layout => CoolLayout }
      }
      @themes = { }
    end
  end
  
  def set(type, name, component, klass)
    hash = type == :game ? @themes : @themes_cat
    name = name.to_s
    hash[name] ||= { }
    hash[name][component] = klass
  end
  
  def load(game, opts = { })
    spec = load_spec(:game => game)
    Theme.new(
      :pieces => read_spec(spec, :pieces).new(:shadow => true),
      :board => read_spec(spec, :board).new(:game => game),
      :clock => read_spec(spec, :clock),
      :layout => read_spec(spec, :layout).new(game)
    )
  end
  
  def load_spec(opts)
    spec = nil
    if opts[:game]
      name = opts[:game].class.data(:id).to_s
      spec = @themes[name] || { }
      spec[:fallback] = load_spec(:category => opts[:game].class.data(:category))
    else
      spec = @themes_cat[opts[:category]] || { }
      spec[:fallback] = @fallback_spec
    end
    spec
  end
  
  def save
    themes_config = KDE::Global.config.group('Themes')
    themes_config.delete_group
    
    game_config = themes_config.group('Games')
    game_config.delete_group
    
    @themes.each do |game, components|
      game_group = game_config.group(game)
      game_group.delete_group
      
      components.each do |component, klass|
        if klass.respond_to? :new
          game_group.write_entry(component.to_s, klass.name)
        end
      end
    end
    
    game_config.sync
    
    cat_config = themes_config.group('Categories')
    cat_config.delete_group
    
    @themes_cat.each do |cat, components|
      cat_group = cat_config.group(cat)
      cat_group.delete_group
      
      components.each do |component, klass|
        if klass.respond_to? :new
          cat_group.write_entry(component.to_s, klass.name)
        end
      end
    end
    
    cat_config.sync
  end
  
  private
  
  def read_spec(spec, component)
    klass = spec[component]
    if not klass and spec[:fallback]
      klass = read_spec(spec[:fallback], component)
    end
    klass
  end
end
