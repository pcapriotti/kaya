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
    config = KDE::Global.config.group('Themes')
    if config.exists
      @themes_cat = { }
      config.group("Categories").each_group do |cat|
        @themes_cat[cat.name] = cat.entry_map.with_symbol_keys
      end
      @themes = { }
      config.group("Games").each_group do |game|
        @themes[game.name] = game.entry_map.with_symbol_keys
      end
    else
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
  
  def load(game, opts = { })
    spec = @themes[game.class.data(:id)]
    unless spec
      _, spec = @themes_cat.find do |category, theme|
        game.class.data(:category) == category
      end
      spec ||= @themes_cat['Chess']
    end
    Theme.new(
      :pieces => spec[:pieces].new(:shadow => true),
      :board => spec[:board].new(:game => game),
      :clock => spec[:clock],
      :layout => spec[:layout].new(game)
    )
  end
  
  def save
  end
end