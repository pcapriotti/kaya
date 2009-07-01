# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/chess/pgn'

module Shogi

class PSN < Chess::PGN
  def read_players(info)
    result = {
      :black => info[:sente],
      :white => info[:gote] }
    info.delete(:sente)
    info.delete(:gote)
    result
  end
  
  def player_tags(players)
    tag(:sente, players[:black]) +
    tag(:gote, players[:white])
  end
end

end
