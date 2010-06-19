# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'interaction/match'
require_bundle 'ics', 'icsplayer'
require_bundle 'ics', 'match_helper'

module ICS

#
# Handler for ICS games.
# 
# Responds to ICS protocol events creating and updating matches.
# Matches are stored in the @matches instance variable. It is possible to
# have more than one match running on ICS because of the observe feature.
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
    # retrieve match and helper
    match, match_info = @matches[style12.game_number]
    helper = MatchHelper.create(style12)
    if helper.nil?
      warn "Unsupported style12. Skipping"
      return
    end
    
    # update match using helper and save it back to the @matches array
    match = helper.get_match(@protocol, match, match_info, style12)
    @matches[style12.game_number] = [match, match_info]
    
    if match.nil?
      return
    elsif match.started?
      match_info[:icsplayer].on_style12(style12)
    else
      helper.start(@protocol, @user, match, match_info, style12)
    end
  end
end

end
