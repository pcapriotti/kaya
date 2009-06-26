require 'games/games'
require 'games/chess/state'
require 'games/chess/move'
require 'games/chess/board'
require 'games/chess/policy'
require 'games/chess/animator'
require 'games/chess/validator'
require 'games/chess/serializer'
require 'games/chess/pgn'

module Chess

Game.add :chess do
  Game.new :size => Point.new(8, 8),
           :policy => Policy.new(Move),
           :state_component => State,
           :state => lambda { state_component.new(board.new, move, piece) },
           :board_component => Board,
           :board => lambda { board_component.new(size) },
           :move => Move,
           :animator => Animator,
           :validator => Validator,
           :piece => Piece,
           :players => [:white, :black],
           :types => [:pawn, :knight, :bishop, :rook, :queen, :king],
           :serializer => lambda {|rep| 
              Serializer.new(rep, validator, move, piece) },
           :keywords => %w(chess),
           
           :game_writer_component => PGN,
           :game_writer => lambda { 
              game_writer_component.new(serializer.new(:compact),
                                        state) },
           :game_reader => lambda { game_writer.new },
           :game_extensions => %w(pgn)
end

Game.add :chess5x5, [:chess] do |chess|
  chess.extend(:size => Point.new(5, 5))
end

end
