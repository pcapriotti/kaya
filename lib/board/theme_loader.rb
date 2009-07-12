# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module ThemeLoader
  attr_reader :loader

  Theme = Struct.new(:pieces, :board, :layout)
  
  def load_theme
    Theme.new.tap do |theme|
      theme.pieces = loader.
        get_matching(:pieces, game.keywords || []).
        new(:game => game, :shadow => true)
      theme.board = loader.
        get_matching(:board, game.keywords || []).
        new(:game => game)
      theme.layout = loader.
        get_matching(:layout, game.keywords || []).
        new(game)
    end
  end
end