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
