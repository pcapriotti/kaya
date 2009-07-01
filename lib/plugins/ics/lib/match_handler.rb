# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'interaction/match'
require_bundle 'ics', 'icsplayer'

module ICS

# Handler for ICS games
# 
class MatchHandler
  include Observer
  
  attr_reader :matches
  
  def initialize(user, protocol)
    @protocol = protocol
    @matches = { }
    @user = user
    
    protocol.add_observer(self)
  end
  
  def on_creating_game(data)
    match = Match.new(data[:game], 
        :kind => :ics, 
        :editable => false)
    @matches[data[:number]] = [match, data]
  end
  
  def on_end_game(data)
    entry = @matches.delete(data[:game_number])
    if entry
      match, info = entry
      match.close(data[:result], data[:message])
    end
  end
  
  def on_style12(style12)
    match, match_info = @matches[style12.game_number]
    return if match == nil
    
    if match.started?
      match.update_time(style12.time)
      if match.index < style12.move_index
        # last_move = icsapi.parse_verbose(style12.last_move, match.state)
        move = match.game.serializer.new(:compact).deserialize(style12.last_move_san, match.state)
        if move
          match.move(nil, move, :state => style12.state)
        else
          warn "Received invalid move from ICS: #{style12.last_move_san}"
        end
      end
    else
      rel = style12.relation
      state = style12.state
      turns = [state.turn, state.opposite_turn(state.turn)]
      @user.color, opponent_color =
        if rel == Style12::Relation::MY_MOVE
          turns
        else
          turns.reverse
        end
      opponent = ICSPlayer.new(
        lambda {|msg| @protocol.connection.send_text(msg) },
        opponent_color,
        match.game.serializer.new(:compact),
        match_info[opponent_color][:name])
      @user.name = match_info[@user.color][:name]
      @user.premove = true
      
      match.register(@user)
      match.register(opponent)
      
      match.start(@user)
      match.start(opponent)
      
      raise "couldn't start match" unless match.started?
      
      @user.reset(match)
      
      match.update_time(style12.time)
    end
    
    
  end
end

end