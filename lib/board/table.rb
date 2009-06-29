# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Table < Qt::GraphicsView
  include Observable
  
  attr_reader :elements

  Theme = Struct.new(:pieces, :board, :layout)

  def initialize(scene, loader, parent)
    super(@scene = scene, parent)
    @loader = loader
  end
  
  def reset(match)
    game = match.game
    # destroy old elements
    if @elements
      @scene.remove_element(@elements[:board])
      @elements[:pools].each do |col, pool|
        @scene.remove_element(pool)
      end
      @elements[:clocks].each do |col, clock|
        @scene.remove_element(clock)
      end
    end
    
    # load theme
    @theme = Theme.new
    @theme.pieces = @loader.
      get_matching(:pieces, game.keywords || []).
      new(:game => game, :shadow => true)
    @theme.board = @loader.
      get_matching(:board, game.keywords || []).
      new(:game => game)
    @theme.layout = @loader.
      get_matching(:layout, game.keywords || []).
      new(game)

    # recreate elements
    @elements = { }
    @elements[:board] = Board.new(@scene, @theme, game)
    @elements[:pools] = if game.respond_to? :pool
      game.players.inject({}) do |res, player|
        res[player] = Pool.new(@scene, @theme, game)
        res
      end
    else
      {}
    end
    clock_class = @loader.get_matching(:clock)
    @elements[:clocks] = game.players.inject({}) do |res, player|
      res[player] = clock_class.new(scene)
      res
    end
    
    relayout
    fire :reset => match
  end

  def flip(value)
    if flipped? != value
      @theme.layout.flip(value)
      @theme.board.flip(value)
      @theme.pieces.flip(value)
      relayout
    end
  end

  def resizeEvent(e)
    @initialized = true
    r = Qt::RectF.new(0, 0, e.size.width, e.size.height)
    @scene.scene_rect = r
    relayout if @elements
  end
  
  def relayout
    if @initialized
      @theme.layout.layout(@scene.scene_rect, @elements)
    end
  end
  
  def flipped?
    @theme.layout.flipped?
  end
end
