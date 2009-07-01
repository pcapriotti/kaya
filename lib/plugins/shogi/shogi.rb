# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/shogi/state'
require 'games/shogi/pool'
require 'games/shogi/move'
require 'games/shogi/validator'
require 'games/shogi/policy'
require 'games/shogi/serializer'
require 'games/shogi/notation'
require 'games/shogi/piece'
require 'games/shogi/psn'
require 'plugins/plugin'
require 'games/game_actions'

module Shogi

class Game
  include Plugin
  include GameActions
  
  plugin :name => 'Shogi',
         :id => :shogi,
         :interface => :game,
         :keywords => %w(shogi),
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
    @notation = Notation.new(piece, size)
    
    @game_writer = PSN.new(serializer.new(:compact), state)
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