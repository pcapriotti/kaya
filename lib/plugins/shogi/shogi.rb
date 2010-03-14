# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require_bundle 'shogi', 'state'
require_bundle 'shogi', 'pool'
require_bundle 'shogi', 'move'
require_bundle 'shogi', 'validator'
require_bundle 'shogi', 'serializer'
require_bundle 'shogi', 'notation'
require_bundle 'shogi', 'piece'
require_bundle 'shogi', 'psn'
require_bundle 'shogi', 'policy'
require 'games/game_actions'
require 'lazy'

module Shogi

class Game
  include Plugin
  include GameActions
  
  plugin :name => KDE::i18n('Shogi'),
         :id => :shogi,
         :interface => :game,
         :category => 'Shogi',
         :depends => [:chess],
         :bundle => 'shogi'
  
  attr_reader :size, :state, :board, :pool,
              :policy, :move, :animator, :validator,
              :piece, :players, :types, :serializer,
              :notation, :game_writer, :game_extensions
              
  def initialize
    @size = Point.new(9, 9)
    @state = Factory.new { State.new(board.new, pool, move, piece) }
    @board = Factory.new { chess.board.component.new size }
    @pool = Pool
    @piece = Piece
    @move = Move
    @validator = Validator
    @animator = chess.animator
    @policy = Factory.new(Policy) { Policy.new(move, validator, true) }
    
    @players = [:black, :white]
    @types = [:pawn, :lance, :horse, :silver, 
              :gold, :bishop, :rook, :king]
              
    @serializer = Factory.new(Serializer) {|rep| 
      Serializer.new(rep, validator, move, piece, notation) }
    @notation = promise { Notation.new(piece, size) }
    
    @game_writer = promise { PSN.new(serializer.new(:compact), state) }
    @game_extensions = %w(psn)
              
    action :autopromote, 
           :checked => true,
           :text => '&Promote Automatically' do |value, policy|
      policy.autopromote = value
    end
  end
  
  def game_reader
    @game_writer
  end
end

end

module MiniShogi

class Game < Shogi::Game
  plugin :name => KDE::i18n('MiniShogi'),
         :id => :minishogi,
         :interface => :game,
         :category => 'Shogi'

  def initialize
    super
    @size = Point.new(5, 5)
    @state = Factory.new { State.new(board.new, pool, move, piece) }
    @game_extensions = []
  end

end

end
