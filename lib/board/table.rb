# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'board/element_manager'

class Table < Qt::GraphicsView
  include Observable
  include ElementManager
  
  attr_reader :elements, :scene, :theme, :game
  private :game, :scene, :theme

  def initialize(scene, loader, parent)
    super(@scene = scene, parent)
    @loader = loader
  end
  
  def reset(match)
    @game = match.game
    # destroy old elements
    if @elements
      @elements.each do |key, element|
        if element.respond_to?(:each)
          element.each do |key, value|
            @scene.remove_element(value)
          end
        else
          @scene.remove_element(element)
        end
      end
    end
    
    theme_loader = @loader.get_matching(:theme_loader).new
    @theme = theme_loader.load(@game)
    @elements = create_elements
    
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
    unless e.size.null?
      @initialized = true
      r = Qt::RectF.new(0, 0, e.size.width, e.size.height)
      @scene.scene_rect = r
      relayout if @elements
    end
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
