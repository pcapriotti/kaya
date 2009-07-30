# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'board/square_tag.rb'
require 'observer'
require 'board/point_converter.rb'
require 'item'
require 'board/item_bag'
require 'board/redrawable'

class Board < Qt::GraphicsItemGroup
  include TaggableSquares
  include Observable
  include PointConverter
  include ItemBag
  include ItemUtils
  include Redrawable
  
  PREMOVE_ZVALUE = 3
  SELECTION_ZVALUE = 4

  attr_reader :scene, :items, :unit, :rect, :theme
  square_tag :selection, :selection, :z => SELECTION_ZVALUE
  square_tag :last_move_src, :highlight
  square_tag :last_move_dst, :highlight
  square_tag :premove_src, :premove, :z => PREMOVE_ZVALUE
  square_tag :premove_dst, :premove, :z => PREMOVE_ZVALUE

  def initialize(scene, theme, game)
    super(nil, scene)
    @scene = scene
    @scene.add_clickable_element(self)
    @theme = theme
    @items = {}
    
    @game = game
    
    @flipped = false
  end
  
  def flipped?
    @flipped
  end
  
  def flip(value)
    @flipped = value
  end
  
  def redraw
    @items.each do |key, item|
      item.reload(key)
    end
  end
  
  def reset(board = nil)
    # create pieces
    if board
      board.to_enum(:each_square).map do |p|
        add_piece(p, board[p], :load => false) if board[p]
      end
    end
    
    # create background item
    add_item :background, nil,
             :reloader => background_reloader,
             :z => BACKGROUND_ZVALUE
             
    redraw if @unit
  end
  
  def set_geometry(rect)
    @rect = rect
    side = [@rect.width / @game.size.x, @rect.height / @game.size.y].min.floor
    @unit = Qt::Point.new(side, side)
    base = Qt::Point.new(((@rect.width - side * @game.size.x) / 2.0).to_i,
                        ((@rect.height - side * @game.size.y) / 2.0).to_i)

    self.pos = (base + @rect.top_left).to_f

    redraw
  end
  
  def add_piece(p, piece, opts = {})
    opts = opts.merge :name => piece,
                      :reloader => piece_reloader(piece)
    item = add_item p, nil, opts
    item.reload(p) if opts.fetch(:load, true)
    item
  end
  
  def create_piece(piece, opts = {})
    opts = opts.merge :name => piece,
                      :reloader => piece_reloader(piece)
    item = create_item p, nil, opts
    item.reload(Qt::PointF.new(0, 0))
    item
  end
  
  def on_click(pos)
    p = to_logical(pos)
    fire :click => p
  end
  
  def on_drag(pos)
    p = to_logical(pos)
    item = items[p]
    if item
      fire :drag => { :src => p, 
                      :item => item,
                      :size => @unit }
    end
  end
  
  def on_drop(old_pos, pos, data)
    if data[:item]
      src = if old_pos
        to_logical(old_pos)
      end
      dst = if pos
        to_logical(pos)
      end
      fire :drop => data.merge(:src => src, :dst => dst)
    end
  end
  
  def highlight(move)
    if move
      self.last_move_src = move.src
      self.last_move_dst = move.dst
    else
      self.last_move_src = nil
      self.last_move_dst = nil
    end
  end
  
  def premove(src, dst)
    self.premove_src = src
    self.premove_dst = dst
  end
  
  def cancel_premove
    premove(nil, nil)
  end
end
