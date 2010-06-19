# Copyright (c) 2010 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require_bundle 'ics', 'style12'

module ICS

# 
# Helper mixin to create and start ICS matches.
# 
module MatchHelper
  #
  # Create an appropriate MatchHelper instance for the given style12
  # 
  def self.create(style12)
    @@helpers ||= {}.tap do |h|
      h[Style12::Relation::EXAMINING] = ExaminingMatchHelper.new
      h[Style12::Relation::NOT_MY_MOVE] = DefaultMatchHelper.new
      h[Style12::Relation::MY_MOVE] = h[Style12::Relation::NOT_MY_MOVE]
    end
    
    @@helpers[style12.relation]
  end
  
  # 
  # Create the opponent player. By default, create an ICSPlayer that
  # will respond to future style12 events.
  # 
  def create_opponent(protocol, color, match, match_info)
    send = lambda {|msg| protocol.connection.send_text(msg) }
    opponent = ICSPlayer.new(send, color, match, match_info)
    match_info[:icsplayer] = opponent
    opponent
  end
  
  # 
  # Create a player for this match.
  # 
  def create_player(user, color, match, match_info)
    raise "not implemented"
  end
  
  # 
  # Perform post-creation initialization for players.
  # 
  def setup_players(user, players)
  end
  
  # 
  # Return or create a match. Called on an existing match when a new style12 
  # event is received.
  # If no match for that style12 event is found, the match argument
  # will be nil.
  # 
  def get_match(protocol, match_info, style12)
    match_info
  end
  
  # 
  # Return an array of colors to be assigned to the players.
  # 
  def colors(state, rel)
    turns = [state.turn, state.opposite_turn(state.turn)]
    if rel == Style12::Relation::NOT_MY_MOVE
      turns.reverse
    else
      turns
    end
  end
  
  # 
  # Start an existing match. Called when the first style12
  # for the given match is received.
  # 
  def start(protocol, user, match, match_info, style12)
    rel = style12.relation
    state = style12.state
    turns = [state.turn, state.opposite_turn(state.turn)]
    
    user_color, opponent_color = colors(state, rel)
        
    # create players
    opponent = create_opponent(protocol, opponent_color, match, match_info)
    player = create_player(user, user_color, match, match_info)
    setup_players(user, [player, opponent])
    
    # start match
    match.register(player)
    match.register(opponent)
    match.start(player)
    match.start(opponent)
    raise "couldn't start match" unless match.started?
    
    # set initial state and time
    unless match_info[:icsapi].same_state(match.state, style12.state)
      match.history.state = style12.state
    end
    match.update_time(style12.time)
    
    # reset controller
    user.reset(match)
  end
end

#
# Helper class to setup normal ICS games.
# 
class DefaultMatchHelper
  include MatchHelper

  def create_player(user, color, match, match_info)
    # do not create a new player, just return user
    user.color = color
    user.premove = true
    user.name = match_info[color][:name]
    user
  end
end

# 
# Helper class to setup matches in examination mode
# 
class ExaminingMatchHelper
  include MatchHelper
  
  def create_player(user, color, match, match_info)
    user.color = nil
    
    # create a controlled player
    player = DummyPlayer.new(color)
    player.name = match_info[color][:name]
    user.premove = false
    player
  end
  
  def setup_players(user, players)
    players.each do |player|
      user.add_controlled_player(player)
    end
  end

  def get_match(protocol, match_info, style12)
    if match_info.nil?
      # Examined games on ics have no header, so we have to be prepared to
      # create a new match on the fly at this point.
      # Create an editable Game.dummy match for the moment.
      match = Match.new(Game.dummy, 
                        :kind => :ics, 
                        :editable => true, :navigable => true)
      match_info = style12.match_info.merge(:type => :examined,
                                            :match => match)
      
      # We want to change the game type at some point, so request the game
      # movelist to the server.
      protocol.connection.send_text('moves')
    end
    
    match_info
  end
end

end
