require 'interaction/match'

module ICS

# Handler for ICS games
# 
class MatchHandler
  include Observer
  
  def initialize(user, protocol)
    @protocol = protocol
    @matches = { }
    @user = user
    
    protocol.add_observer(self)
  end
  
  def on_creating_game(data)
    match = Match.new(data[:game])
    @matches[data[:number]] = [match, data[:icsapi]]
  end
  
  def on_style12(style12)
    match, icsapi = @matches[style12[:game_number]]
    return if match == nil
    
    unless match.started?
      rel = style12[:relation]
      state = style12[:state]
      turns = [state.turn, state.opposite_turn(state.turn)]
      user_color, opponent_color =
        if rel == Style12::Relation::MY_MOVE
          turns
        else
          turns.reverse
        end
      user.reset(user_color, match)
      opponent = ICSPlayer.new
        lambda {|msg| @protocol.connection.send_text(msg),
        opponent_color
      
      match.register(user)
      match.register(opponent)
      
      match.start(user)
      match.start(opponent)
    end
    
    if style12[:move_index] > 0
      last_move = icsapi.parse_verbose(style12[:last_move], style12[:state])
      move = match.game.read_move(style12[:last_move_san], style12[:state])
      if last_move != move
        warn "[server inconsistency] " +
             "SAN for last move is different from verbose notation"
      end
      
      match.move(nil, move)
    end
    
    
  end
end

end