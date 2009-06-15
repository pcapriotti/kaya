require 'games/shogi/state'
require 'games/shogi/pool'
require 'games/shogi/move'
require 'games/shogi/validator'
require 'games/chess/chess'

module Shogi

Game.get(:chess).tap do |chess|
  Game.add :shogi, Game.new(
    :size => Point.new(9, 9),
    :state => lambda { State.new(board.new, pool, move, piece) },
    :board => lambda { chess.board_component.new size },
    :pool => Pool,
    :policy => chess.policy,
    :move => Move,
    :animator => chess.animator,
    :validator => Validator,
    :piece => chess.piece)
end

end