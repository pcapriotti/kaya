# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/games'
require_bundle 'chess', 'state'
require_bundle 'chess', 'move'
require_bundle 'chess', 'board'
require_bundle 'chess', 'policy'
require_bundle 'chess', 'animator'
require_bundle 'chess', 'validator'
require_bundle 'chess', 'serializer'
require_bundle 'chess', 'pgn'
require_bundle 'chess', 'san'
require 'plugins/plugin'
require 'games/game_actions'
require 'lazy'

module Chess

class Game
  include Plugin
  include GameActions
  
  plugin :name => KDE::i18n('Chess'),
         :id => :chess,
         :interface => :game,
         :category => 'Chess',
         :bundle => 'chess'
         
  attr_reader :size, :policy, :state, :board, :move,
              :animator, :validator, :piece, :players,
              :types, :serializer, :game_writer,
              :game_extensions, :notation
              
  def initialize
    @size = Point.new(8, 8)
    @state_component = State
    @state = Factory.new(State) { State.new(board.new, move, piece) }
    @board = Factory.new(Board) { Board.new(size) }
    @move = Move
    @animator = Animator
    @validator = Validator
    @piece = Piece
    @policy = Factory.new(Policy) { Policy.new(move) }
    @players = [:white, :black]
    @types = [:pawn, :knight,:bishop, :rook, :queen, :king]
    @notation = promise { SAN.new(piece, size) }
    @serializer = Factory.new(Serializer) {|rep| 
      Serializer.new(rep, validator, move, piece, notation) }
    @keywords = %w(chess)

    @game_writer = promise { PGN.new(serializer.new(:compact), state) }
    @game_extensions = %w(pgn)
    
    action :promote_to_queen,
           :text => KDE::i18n('Promote to &Queen') do |policy| 
      policy.promotion = :queen
    end
    action :promote_to_rook, 
           :text => KDE::i18n('Promote to &Rook') do |policy| 
      policy.promotion = :rook
    end
    action :promote_to_bishop, 
           :text => KDE::i18n('Promote to &Bishop') do |policy| 
      policy.promotion = :bishop
    end
    action :promote_to_knight, 
           :text => KDE::i18n('Promote to &Knight') do |policy| 
      policy.promotion = :knight
    end
  end
  
  def game_reader
    @game_writer
  end
  
  def actions(parent, collection, policy)
    acts = super
    group = Qt::ActionGroup.new(parent)
    group.exclusive = true
    acts.each do |act| 
      act.checkable = true
      act.action_group = group
    end
    acts.first.checked = true
    acts
  end
end

end

module Chess5x5

class Game < Chess::Game
  plugin :name => KDE::i18n('Chess 5x5'),
         :id => :chess5x5,
         :interface => :game,
         :category => 'Chess'
  
  def initialize
    super
    @size = Point.new(5, 5)
    @game_extensions = []
  end
  
end

end
