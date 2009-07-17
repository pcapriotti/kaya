# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require 'interaction/history'
require 'interaction/undo_manager'

module Player
  def name
  end

  def inspect
    "<#{name}:#{self.class.name}>"
  end
end

class Match
  include Observable
  
  GameNotStarted = Class.new(Exception)
  
  attr_reader :game
  attr_reader :kind
  attr_accessor :url
  
  def initialize(game, opts = {})
    @game = game
    @players = { } # player => ready
    @history = nil
    @kind = opts[:kind] || :local
    @editable = opts.fetch(:editable, true)
    @closed = false
    @info = { }
  end
  
  def register(player)
    return false if @history
    return false if @players.has_key?(player)
    return false if complete?
    return false unless @game.players.include?(player.color)
    
    @players[player] = false
    fire :complete if complete?
    true
  end
  
  def start(player)
    return false if @history
    return false unless complete?
    return false unless @players[player] == false
    
    @players[player] = true
    if @players.values.all?
      state = @game.state.new
      state.setup
      @history = History.new(state)
      fire :started
    end

    true
  end
  
  def move(player, move, opts = {})
    cancel_undo
    return false if @closed
    return false unless @history
    
    # if the match is non-editable, jump to the last move    
    unless editable?
      @history.go_to_last 
    end
    
    # if player is nil, assume the current player is moving
    if player == nil
      player = current_player
    else
      return false unless @players.has_key?(player)
      return false unless player.color == @history.state.turn
    end

    validate = @game.validator.new(@history.state)
    valid = validate[move]
    unless valid
      warn "Invalid move from #{player.name}: #{move}"
      return false 
    end

    old_state = @history.state
    state = old_state.dup
    state.perform! move
    @history.add_move(state, move, opts)
    
    broadcast player, :move => {
      :player => player,
      :move => move,
      :state => state,
      :old_state => old_state }
    true
  end
  
  def undo!(player)
    cancel_undo
    @manager = UndoManager.new(@players.keys)
    @manager.observe(:execute) do |moves|
      if moves
        moves.times do
          history.undo!
        end
      end
      @manager = nil
    end
    @manager.undo(player, 1, :allow_more => true)
    
    # request permission from other players
    @players.keys.each do |p|
      p.allow_undo?(p, @manager) unless p == player
    end
  end
  
  def redo!(player)
    cancel_undo
    history.redo!
    true
  end
  
  def update_time(time)
    broadcast nil, :time => time
  end
  
  def complete?
    @game.players.all? do |c| 
      @players.keys.find {|p| p.color == c }
    end
  end
  
  def started?
    ! ! @history
  end
  
  def state
    @history[index].state
  end
  
  def editable?
    @editable
  end
    
  def player(color)
    @players.keys.find{|p| p.color == color }
  end
  
  def current_player
    player(state.turn)
  end
  
  # end the match
  # players must not send any more 'move' events to
  # a closed game
  # 
  def close(result = nil, message = nil)
    cancel_undo
    @info[:result] = result if result
    broadcast nil, :close => { 
      :result => result,
      :message => message }
    @closed = true
  end
  
  def info
    @info.merge(:players => @players.keys)
  end
  
  def add_info(infos)
    @info = @info.merge(infos)
    infos[:players].each do |col, name|
      p = player(col)
      if p
        p.name = name
      end
    end
  end

  def index
    @history.size - 1
  end
  
  def history
    @history or raise(GameNotStarted)
  end
  
  def history=(history)
    @history = history
  end
    
  private
  
  def broadcast(player, event)
    fire event
    @players.each_key do |p|
      p.update any_to_event(event) unless p == player
    end
  end
  
  def cancel_undo
    @manager.cancel if @manager
    @manager = nil
  end
end