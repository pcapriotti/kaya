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
    @themes = {
      'Chess' => { :pieces => CelticPieces,
                   :board => XBoardBackground,
                   :clock => XBoardClock,
                   :layout => XBoardLayout },
      'Shogi' => { :pieces => ShogiPieces,
                   :board => ShogibanBackground,
                   :clock => BubblesClock,
                   :layout => CoolLayout }
    }
  end
  
  def load(game, opts = { })
    # TODO: load theme from the configuration file
    _, spec = @themes.find do |category, theme|
      game.class.data(:category) == category
    end
    spec ||= @themes['chess']
    Theme.new(
      :pieces => spec[:pieces].new(:shadow => true),
      :board => spec[:board].new(:game => game),
      :clock => spec[:clock],
      :layout => spec[:layout].new(game)
    )
  end
end