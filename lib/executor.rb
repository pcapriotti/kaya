# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Executor
  def execute_move(src, dst, opts = { })
    state = match.history.state
    move = policy.new_move(state, src, dst)
    validate = match.game.validator.new(state)
    if validate[move]
      perform!(move, opts)
      move
    end
  end

  def execute_drop(item, dst)
    state = match.history.state
    move = policy.new_move(state, nil, dst,
                            :dropped => item.name)
    validate = match.game.validator.new(state)
    if validate[move]
      perform! move, opts.merge(:adjust => true, :dropped => item)
      move
    end
  end
  
  def execute_direct_drop(color, index, dst, opts = { })
    state = match.history.state
    item = @pools[color].items[index]
    if item
      move = policy.new_move(state, nil, dst,
                             :dropped => item.name)
      validate = match.game.validator.new(state)
      if validate[move]
        perform! move, opts
        move
      end
    end
  end
end