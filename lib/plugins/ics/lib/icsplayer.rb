# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'interaction/match'

module ICS

# 
# This class represents a remote player on ICS.
# 
class ICSPlayer
  include Player
  include Observer
  
  attr_reader :color, :name
  
  #
  # Create a new ICS player playing with the given color and using the given
  # output channel to send moves.
  # 
  # The out parameter is a Proc that will be used to send data to the server.
  # 
  def initialize(out, color, match, match_info)
    @color = color
    @out = out
    @match = match
    @serializer = match.game.serializer.new(:simple)
    @match_info = match_info
    @name = match_info[color][:name]
    @expected_navigations = []
  end

  # 
  # Send a move to the server.
  # 
  def on_move(data)
    text = @serializer.serialize(data[:move], 
                                 data[:old_state])
    @out[text]
  end
  
  # 
  # Send the server a request to move backwards.
  # 
  def on_back(opts)
    @out['back']
    add_expected_navigation(opts)
  end
  
  # 
  # Send the server a request to move forward.
  #   
  def on_forward(opts)
    @out['forward']
    add_expected_navigation(opts)
  end
  
  # 
  # Send a navigation request to the server.
  # 
  def on_go_to(data)
    delta = data[:index] - data[:old_index]
    add_expected_navigation(data) unless delta == 0
    if delta > 0
      @out["forward #{delta}"]
    elsif delta < 0
      @out["back #{-delta}"]
    end
  end
  
  # 
  # Use the takeback command to request an undo.
  # 
  def allow_undo?(player, manager)
    # request undo
    @out['takeback']
    # disallow for now
    manager.undo(self, nil)
  end
  
  # 
  # Process an incoming style12 event.
  # 
  def on_style12(style12)
    @match.update_time(style12.time)
    delta = style12.move_index - @match.index
    
    # get previously stored revert information
    revert_to = @match_info[:about_to_revert_to]
    @match_info.delete(:about_to_revert_to)
    
    if revert_to and revert_to != style12.move_index
      warn "ICS inconsistency: style12 and revert message refer to" +
       "different indexes (resp. #{style12.move_index} and #{revert_to}"
    end
    
    # check expected navigations
    exp = @expected_navigations.shift
    if exp
      if exp != style12.move_index || revert_to
        # unexpected navigation, clear expected queue
        @expected_navigations = []
      else
        if exp == 0 || 
           @match_info[:icsapi].
             same_state(style12.state, 
                        @match.history[exp].state)
          # we were expecting this, no need to take further action
          return
        end
      end
    end
    
    if delta > 1
      (delta - 1).times do
        @match.history.add_placeholder
      end
      delta = 1
    end
    
    if delta == 1
      # standard case: advancing forward by 1
      if @match.valid_state?
        move = @serializer.deserialize(style12.last_move_san, @match.state)
      end
      if move.nil?
        # An invalid move can happen when the game used locally does not
        # correspond to the actual played game.
        # This is sometimes inevitable, since ICS does not send a header
        # when beginning examination.
        # In this case, force the move into the history, and be careful to
        # use the SAN provided in the style12 event for rendering.
        warn "Received invalid move from ICS: #{style12.last_move_san}"
        move = @match_info[:icsapi].parse_last_move(style12.last_move, style12.state.turn)
        @match.history.add_move(style12.state, move, :text => style12.last_move_san)
      else
        # Perform and store a new move.
        @match.move(self, move)
        unless @match_info[:icsapi].
                 same_state(style12.state, 
                            @match.state)
          @match.history.state = style12.state.dup
        end
      end
    elsif delta <= 0
      move = if style12.move_index > 0
        @serializer.deserialize(
          style12.last_move_san, 
          @match.history[style12.move_index - 1].state)
      end
      state = @match_info[:icsapi].
        amend_state(@match.history[style12.move_index].state, 
                    style12.state)
      if @match.navigable? && (!revert_to)
        @match.history.go_to(style12.move_index)
        @match.history.set_item(state, move)
      else
        @match.history.remove_items_at(style12.move_index + 1)
        @match.history.set_item(state, move)
      end
    else
      move = @match_info[:icsapi].parse_last_move(style12.last_move, style12.state.turn)
      if move
        @match.history.add_move(style12.state, move, :text => style12.last_move_san)
      else
        warn "Invalid last move #{style12.last_move}"
      end
    end
  end
  
  private
  
  def add_expected_navigation(opts = {})
    @expected_navigations << @match.index unless opts[:awaiting_server] 
  end
end

end