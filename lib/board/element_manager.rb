# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'board/board'
require 'board/pool'

module ElementManager
  def create_elements
    Hash.new.tap do |elements|
      elements[:board] = Board.new(scene, theme, game)
      elements[:pools] = if game.respond_to? :pool
        game.players.inject({}) do |res, player|
          res[player] = Pool.new(scene, theme, game)
          res
        end
      else
        {}
      end
      elements[:clocks] = game.players.inject({}) do |res, player|
        res[player] = theme.clock.new(scene)
        res
      end
      theme.layout.setup(elements)
    end
  end
end