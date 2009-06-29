# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'animator_helper'

class PoolAnimator
  include AnimatorHelper
  
  attr_reader :pool
  alias :board :pool # for AnimatorHelper
  
  def initialize(pool)
    @pool = pool
  end
  
  def warp(pool)
    pieces = pool.pieces.
      map{|piece, count| [piece] * count}.
      inject([]){|a, b| a.concat(b)}.
      sort {|p1, p2| board.compare(p1, p2) }
      
    anims = []
      
    index = 0
    while index < pieces.size
      # precondition: pool and graphical pool match up to index
    
      # no more sprites on the graphical pool
      if index >= board.items.size
        # add extra sprites
        (index...pieces.size).each do |i|
          anims << appear_on!(i, pieces[i])
        end
  
        # done
        break;
      end
      
      piece = pieces[index]
      item = board.items[index]
      i = pieces[index..-1].detect_index {|p| item.name == p }
      
      if i
        # matching piece found on the pool
        # insert all pieces before this one on the graphical pool
        (index...index + i).each do |j|
          anims << insert_piece(j, pieces[j])
        end
        index += i + 1
      else
        # no such piece found: remove it from the graphical pool
        anims << remove_piece(index)
      end
    end
    
    while board.items.size > pieces.size
      anims << disappear_on!(pieces.size)
    end
    
    group(*anims)
  end
  
  def insert_piece(index, piece)
    anim = appear_on! index, piece
    
    # shift following items to make room
    shift = (index + 1...board.items.size).map do |i|
      movement(board.items[i], i - 1, i, Path::Linear)
    end
    
    group(anim, *shift)
  end
  
  def remove_piece(index)
    anim = disappear_on! index

    # shift following items to fill void
    shift = (index...board.items.size).map do |i|
      movement(board.items[i], i + 1, i, Path::Linear)
    end
    
    group(anim, *shift)
  end
end
