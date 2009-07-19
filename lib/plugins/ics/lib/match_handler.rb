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
        :editable => false,
        :time_running => true)
    @matches[data[:number]] = [match, data.merge(:type => :played)]
  end
  
  def on_end_game(data)
    entry = @matches.delete(data[:game_number])
    if entry
      match, info = entry
      match.close(data[:result], data[:message])
    end
  end
  
  def on_end_examination(number)
    on_end_game(:game_number => number,
                :result => '',
                :message => '')
  end
  
  def on_examination_revert(data)
    match, match_info = @matches[data[:game_number]]
    if match_info
      match_info[:about_to_revert_to] = data[:index]
    end
  end
  
  def on_style12(style12)
    match, match_info = @matches[style12.game_number]
    if match.nil? && style12.relation == Style12::Relation::EXAMINING
      # if it is an examined game, start a new match
      match = Match.new(Game.dummy, :kind => :ics, :editable => true, :navigable => true)
      match_info = style12.match_info.merge(:type => :examined)
      @matches[style12.game_number] = [match, match_info]
    end
    
    if match.started?
      match_info[:icsplayer].on_style12(style12)
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
        match,
        match_info)
      match_info[:icsplayer] = opponent
      @user.name = match_info[@user.color][:name]
      
      # in examined games, playing moves for the opponent is allowed
      if match_info[:type] == :examined
        @user.add_controlled_player(opponent)
        @user.premove = false
      else
        @user.premove = true
      end
      
      match.register(@user)
      match.register(opponent)
      
      match.start(@user)
      match.start(opponent)
      
      raise "couldn't start match" unless match.started?
      unless match_info[:icsapi].same_state(match.state, style12.state)
        match.history.state = style12.state
      end
      
      @user.reset(match)
      
      match.update_time(style12.time)
    end
    
    
  end
end

end