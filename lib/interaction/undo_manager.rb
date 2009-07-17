# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'

class UndoManager
  include Observable
  DuplicatedUndoInformation = Class.new(Exception)
  
  def initialize
    @players = { }
  end
  
  def undo(player, moves, opts = { })
    raise DuplicatedUndoInformation if @players[player]
    @players[player] = {
      :moves => moves,
      :more => opts[:allow_more] }
  end
  
  def complete
    fire :complete => find_common
  end
  
  private
  
  def find_common
    common = 1
    common_more = true
    
    @players.each do |player, data|
      return nil unless data[:moves]
      if common.nil? || data[:moves] > common
        return nil unless common_more
        common = data[:moves]
        common_more = data[:more]
      elsif data[:moves] < common
        return nil unless data[:more]
      end        
    end
    
    common
  end
end