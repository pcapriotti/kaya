# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Premover
  # Create a premover object
  # executor: an object with execute_move and execute_direct_drop methods
  # board: a graphical board
  # pools: a hash of graphical pools
  # 
  def initialize(executor, board, pools)
    @executor = executor
    @board = board
    @pools = pools
  end
  
  def execute
    if @board.premove_dst
      if @board.premove_src
        @executor.execute_move(@board.premove_src, @board.premove_dst)
      else
        @pools.each do |color, pool|
          if pool.premove_src
            @executor.execute_direct_drop(color, pool.premove_src, @board.premove_dst)
            break
          end
        end
      end
    end
    cancel
  end

  def move(src, dst)
    cancel
    if src != dst
      @board.premove(src, dst)
    end
  end
  
  def drop(color, index, dst)
    cancel
    @board.premove_dst = dst
    @pools[color].premove_src = index
  end
  
  def cancel
    @board.cancel_premove
    @pools.each do |color, pool|
      pool.premove_src = nil
    end
  end
end