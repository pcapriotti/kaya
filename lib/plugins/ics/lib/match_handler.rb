# Copyright (c) 2009-2010 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'interaction/match'
require 'dummy_player'
require_bundle 'ics', 'icsplayer'
require_bundle 'ics', 'match_helper'

module ICS

#
# Responds to ICS protocol events creating and updating matches.
# 
# Only one match handler per ICS connection is required. Each game created,
# game deleted, and style12 event for the given connection is handled by
# this object.
# 
# A map of matches by ICS game number is maintained in the @matches instance
# variable. It is possible to have more than one match running at the same
# time, since multiple games can be observed.
# 
class MatchHandler
  include Observer
  
  attr_reader :matches
  
  # 
  # Create a match handler for the ICS connection associated to protocol.
  # 
  def initialize(user, protocol)
    @protocol = protocol
    @matches = { }
    @user = user
    
    protocol.add_observer(self)
  end
  
  # 
  # Create a new match.
  # 
  # This method is called whenever a new game is created on the server.
  # The match_info structure is filled by the protocol.
  # 
  def on_creating_game(data)
    helper = MatchHelper.get(data[:helper] || :default)
    match_info = helper.create_match(data)
    @matches[match_info[:number]] = match_info
  end
  
  # 
  # Remove a match.
  # 
  def on_end_game(data)
    match_info = @matches.delete(data[:game_number])
    if match_info
      match = match_info[:match]
      match.close(data[:result], data[:message])
    end
  end
  
  # 
  # Remove an examined game. Simply delegate to on_end_game.
  # 
  def on_end_examination(number)
    on_end_game(:game_number => number,
                :result => '',
                :message => '')
  end
  
  # 
  # When reverting, set the :about_to_revert_to property to the
  # move index we are about to revert to.
  # 
  # This is used by ICSPlayer to discard any expected navigation
  # information on revert.
  # 
  def on_examination_revert(data)
    match_info = @matches[data[:game_number]]
    if match_info
      match_info[:about_to_revert_to] = data[:index]
    end
  end
  
  # 
  # Forward a style12 event to the appropriate ICSPlayer.
  # Special care is required in some cases, because ICS can issue style12
  # events without any sort of header.
  # This function takes care of creating a match when a style12 event for
  # an unknown match is received, and to start a match when the first style12
  # arrives.
  # 
  def on_style12(style12)
    puts "matches = #{@matches.size}"
    # retrieve match and helper
    helper = MatchHelper.from_style12(style12)
    if helper.nil?
      warn "Unsupported style12. Skipping"
      return
    end
    match_info = @matches[style12.game_number]
    if match_info and match_info[:match] and match_info[:match].closed?
      @matches.delete(style12.game_number)
      helper.close_match(@protocol, match_info)
      return
    end
    
    # update match using helper and save it back to the @matches array
    match_info = helper.get_match(@protocol, match_info, style12)
    @matches[style12.game_number] = match_info
    
    return unless match_info
    match = match_info[:match]
    
    if match.started?
      match_info[:icsplayer].on_style12(style12)
    else
      helper.start(@protocol, @user, match_info, style12)
    end
  end
end

end
