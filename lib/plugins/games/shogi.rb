require 'games/shogi/state'
require 'games/shogi/pool'
require 'games/shogi/move'
require 'games/shogi/validator'
require 'games/shogi/policy'
require 'plugins/plugin'

module Shogi

class Game
  include Plugin
  
  plugin :name => 'Shogi',
         :id => :shogi,
         :interface => :game,
         :keywords => %w(shogi),
         :depends => [:chess]
  
  attr_reader :size, :state, :board, :pool,
              :policy, :move, :animator, :validator,
              :piece, :players, :types, :actions
              
  def initialize
    @size = Point.new(9, 9)
    @state = Factory.new { State.new(board.new, pool, move, piece) }
    @board = Factory.new { chess.board.component.new size }
    @pool = Pool
    @piece = chess.piece
    @move = Move
    @validator = Validator
    @animator = chess.animator
    @policy = Policy.new(move, validator)
    
    @players = [:white, :black]
    @types = [:pawn, :lance, :horse, :silver, 
              :gold, :bishop, :rook, :king]
  end
end

end