# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require 'interaction/match'
require_bundle 'engines', 'engine'

class XBoardEngine < Engine
  include Plugin
  include Observable
  
  plugin :name => 'XBoard Engine Protocol',
         :protocol => 'XBoard',
         :interface => :engine
  
  FEATURES = %w(ping setboard playother san usermove time draw sigint sigterm
                reuse analyze myname variants colors ics name pause done)
  
  def setup
    super
    @ping = 0
    @opts[:debug] = true
    @features = { }
    send_command "xboard"
    send_command "" # an empty line helps getting rid of the prompt
  end
  
  def on_move(data)
    text = @serializer.serialize(data[:move], data[:old_state])
    send_command text
    @engine_turn = @match.state.turn
    unless @playing
      send_command "go"
      @playing = true
    end
  end

  
  def on_engine_start
    send_command "protover 2"
    send_command "nopost"
    send_command "new"
    send_command "force"
    @engine_turn = @match.game.players.first
    if @color == @engine_turn
      send_command "go"
      @playing = true
    end
  end

  def on_command_feature(*args)
    args.each do |arg|
      if arg =~ /^(\S+)=(\S+)$/
        feature = $1
        value = $2.gsub(/(^")|"$/, '')
        if FEATURES.include?(feature)
          @features[feature] = case value
          when '1'
            true
          when '0'
            false
          else
            value
          end
          send_command "accepted #{feature}"
        else
          send_command "rejected #{feature}"
        end
      end
    end
  end
  
  def on_command_move(move)
    if @undo_requested
      # We receive a move now because the engine is dumb and not 
      # able to process our undo request while thinking.
      # We try to be smart here and ignore this move, while telling
      # the engine to undo it.
      # Since the following 'undo' command will be received _after_
      # 'force', there is no risk of having the engine repeat it
      # (undoing an engine move outside of force mode results in
      # undefined behavior).
      send_command 'undo'
      return
    end
    
    # ignore any sign of wrong synchronization
    # no point in trying to recover, it can also mean that
    # the engine is broken
    if @color == @match.state.turn
      move = @serializer.deserialize(move, @match.state)
      if move
        @engine_turn = @match.state.opposite_turn(@match.state.turn)
        @match.move(self, move)
      else
        warn "Illegal move #{move} received from engine #{name}"
      end
    else
      warn "Engine #{name} sent a move on the wrong turn"
    end
  end
  
  def on_command_pong(number)
    fire :pong => number
  end
  
  def extra_command(text)
    if text =~ /^My move is: (.*)$/
      on_command_move($1)
    end
  end
  
  def on_close(data)
    send_command "quit"
  end
  
  def move_now
    # send a SIGINT whenever the platform allows
    begin
      Process.kill("INT", @engine.pid)
    rescue
    end
    send_command '?' 
  end
  
  def allow_undo?(player, manager)
    manager.on(:complete) do |moves|
      # Important note: this block may be called when the match state
      # and the engine internal state are not synchronized. For example,
      # the engine can make a move while the undo process is happening,
      # causing a cancellation before the match has a chance to update the
      # history.
      case moves
      when 1
        send_command "undo"
        @engine_turn = @match.state.opposite_turn(@engine_turn)
      when 2
        send_command "remove"
      end
      if (!@playing) and @color == @engine_turn
        send_command "go"
      end
      @undo_requested = nil
    end
    
    # safe, because undo requests cannot be nested
    @undo_requested = true
    
    if @features['ping']
      send_command 'force'
      move_now
      # If the engine is not playing, this has no effect.
      # Otherwise, it will cause a temporary move to be performed, which
      # will be immediately retracted.
      @playing = false
      # wait for the 'force' and '?' commands to be processed, 
      # to avoid race conditions
      sync do
        moves = if @color == @match.state.turn
          # engine's turn, just undo the last move
          1
        else
          # player's turn, go back two moves
          2
        end
        manager.undo(self, moves)
      end
      true
    else
      # When no ping feature is present, sync cannot be used
      # so there's no way to do an undo without possibly incurring
      # in race conditions (e.g. a move can be sent by the engine
      # in the exact moment when the undo command is received).
      # So in this case, we only allow un undo when it's not the engine
      # turn.
      moves = if @color == @match.state.turn
        warn "Cannot undo on engine's turn because this\n" + 
             "engine does not support the ping command."
        nil
      else
        2
      end
      manager.undo(self, moves)
    end
  end

  # Execute block with the guarantee that all preceding commands
  # have been received and processed by the engine.
  # Requires the 'ping' feature.
  # 
  def sync
    ping = @ping += 1
    send_command "ping #{ping}"
    
    observe_limited(:pong) do |pong|
      if pong.to_i == ping
        @ping -= 1
        yield
        true # remove the observer
      end
    end
  end
end

