# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'plugins/plugin'
require_bundle 'crazyhouse', 'piece'
require_bundle 'crazyhouse', 'state'
require_bundle 'crazyhouse', 'validator'
require_bundle 'crazyhouse', 'serializer'

module Crazyhouse
  
class Game
  include Plugin
  
  plugin :name => 'Crazyhouse',
         :interface => :game,
         :id => :crazyhouse,
         :keywords => %w(chess),
         :depends => [:chess, :shogi],
         :bundle => 'crazyhouse'

  attr_reader :size, :state, :board, :pool,
              :policy, :move, :animator, :validator,
              :piece, :players, :types, :serializer,
              :notation, :game_writer, :game_extensions
              
  def initialize
    @size = Point.new(8, 8)
    @state = Factory.new(State) do
      State.new(board.new, pool, move, piece)
    end
    @board = chess.board
    @pool = shogi.pool
    @piece = Piece
    @move = shogi.move
    @validator = Validator
    @animator = chess.animator
    @policy = chess.policy
    
    @players = [:white, :black]
    @types = [:pawn, :knight, :bishop, :rook, :queen, :king]
              
    @serializer = Factory.new(Serializer) do |rep|
      Serializer.new(rep, validator, move, piece, notation)
    end
    @notation = chess.notation
    
    @game_writer = chess.game_writer
    @game_extensions = []
  end
end
  
end
