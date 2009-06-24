require 'interaction/match'
require 'ics/icsplayer'

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
    match = Match.new(data[:game], :ics)
    @matches[data[:number]] = [match, data[:icsapi]]
  end
  
  def on_style12(style12)
    match, icsapi = @matches[style12.game_number]
    return if match == nil
    
    if match.started?
      puts "match.index = #{match.index}"
      puts "move index = #{style12.move_index}"
      puts "current state = #{match.state}"
      if match.index < style12.move_index
        # last_move = icsapi.parse_verbose(style12.last_move, match.state)
        move = match.game.serializer.new(:compact).deserialize(style12.last_move_san, match.state)
#         if last_move != move
#           warn "[server inconsistency] " +
#                 "SAN for last move is different from verbose notation"
#         end
        if move
          match.move(nil, move, style12.state)
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
        match.game.serializer.new(:compact))
      
      match.register(@user)
      match.register(opponent)
      
      match.start(@user)
      match.start(opponent)
      
      raise "couldn't start match" unless match.started?
      
      @user.reset(match)
    end
    
    
  end
end

end