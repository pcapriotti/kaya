require 'games/shogi/state'
require 'games/shogi/pool'
require 'games/shogi/move'
require 'games/shogi/validator'

Games.get(:chess).tap(:chess) do |chess|
  Games.add :shogi,
    :size => Point.new(9, 9),
    :state => Factory.new { State.new(board.new, pool, move, piece) }
    :board => chess.board,
    :pool => Pool,
    :policy => chess.policy,
    :move => Move,
    :animator => chess.animator,
    :piece => chess.piece
end
