require 'games/shogi/state'
require 'games/shogi/pool'
require 'games/shogi/move'
require 'games/shogi/validator'
require 'games/shogi/policy'
require 'games/shogi/serializer'
require 'games/shogi/notation'
require 'games/shogi/piece'
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
         :depends => [:chess]
  
  attr_reader :size, :state, :board, :pool,
              :policy, :move, :animator, :validator,
              :piece, :players, :types, :serializer,
              :notation
              
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
              
    action :autopromote, 
           :checked => true,
           :text => '&Promote Automatically' do |value, policy|
      policy.autopromote = value
    end
  end
end

end