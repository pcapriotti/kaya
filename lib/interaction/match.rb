require 'observer_utils'

module Player
  include Observer
end

class Match
  include Observable
  
  attr_reader :game
  attr_reader :state
  attr_reader :index
  
  def initialize(game)
    @game = game
    @players = { } # player => ready
    @state = nil
  end
  
  def register(player)
    return false if @state
    return false if @players.has_key?(player)
    return false if complete?
    return false unless @game.players.include?(player.color)
    
    @players[player] = false
    fire :complete if complete?
    true
  end
  
  def start(player)
    return false if @state
    return false unless complete?
    return false unless @players[player] == false
    
    @players[player] = true
    if @players.values.all?
      @state = @game.state.new
      @state.setup
      @index = 0
      fire :started
    end
    
    true
  end
  
  def move(player, move, state)
    return false unless @state
    # if player is nil, assume the current player is moving
    if player == nil
      player = current_player
    else
      return false unless @players.has_key?(player)
      return false unless player.color == @state.turn
    end

    validate = @game.validator.new(@state)
    valid = validate[move]
    return false unless valid
    
    old_state = @state
    if state
      @state = state.dup
    else
      old_state = @state.dup
      @state.perform!(move)
    end
    
    @index += 1
    broadcast player, :move => {
      :player => player,
      :move => move,
      :state => @state,
      :old_state => old_state}
    true
  end
  
  def complete?
    @game.players.all? do |c| 
      @players.keys.find {|p| p.color == c }
    end
  end
  
  def started?
    ! ! @state
  end
  
  private
  
  def broadcast(player, event)
    fire event
    @players.each_key do |p|
      p.update any_to_event(event) unless p == player
    end
  end
  
  def current_player
    @players.keys.find {|p| p.color == @state.turn }
  end
end