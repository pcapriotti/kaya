require 'games/shogi/state'
require 'games/shogi/pool'
require 'games/shogi/move'
require 'games/shogi/validator'
require 'games/shogi/policy'

module Shogi

Game.add :shogi, [:chess] do |chess|
  Game.new :size => Point.new(9, 9),
           :state => lambda { State.new(board.new, pool, move, piece) },
           :board => lambda { chess.board_component.new size },
           :pool => Pool,
           :policy => Policy.new(Move, Validator),
           :move => Move,
           :animator => chess.animator,
           :validator => Validator,
           :piece => chess.piece,
           :keywords => %w(shogi),
           :players => [:black, :white],
           :serializer => chess.serializer,
           :types => [:pawn, :lance, :horse, :silver, :gold, :bishop, :rook, :king]
end

end