# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'

class UndoManager
  include Observable
  DuplicateUndoInformation = Class.new(Exception)
  NoSuchPlayer = Class.new(Exception)
  
  def initialize(players)
    @players = { }
    players.each do |player|
      @players[player] = nil
    end
  end
  
  def undo(player, moves, opts = { })
    unless @cancelled
      raise NoSuchPlayer unless @players.has_key?(player)
      unless @players[player].nil?
        raise DuplicateUndoInformation.new(
          "player #{player.inspect} already specified undo information")
      end
      @players[player] = {
        :moves => moves,
        :more => opts[:allow_more] }
      if @players.all?{|p, info| info }
        common = find_common
        fire :complete => common
        fire :execute => common
      end
    end
  end
  
  def cancel
    @cancelled = true
    fire :complete => nil
  end
  
  private
  
  def find_common
    common = 1
    common_more = true
    
    @players.each do |player, data|
      if data
        return nil unless data[:moves]
        if common.nil? || data[:moves] > common
          return nil unless common_more
          common = data[:moves]
          common_more = data[:more]
        elsif data[:moves] < common
          return nil unless data[:more]
        end
      end
    end
    
    common
  end
end