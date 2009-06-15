require 'games/chess/state'
require 'games/chess/move'
require 'games/chess/board'
require 'games/chess/policy'
require 'games/chess/animator'
require 'games/chess/validator'
require 'games/factory'

Games.add :chess,
  :size => Point.new(8, 8)
  :policy => Policy,
  :state => Factory.new { State.new(board.new, move, piece) },
  :board => Factory.new { Board.new(size) },
  :move => Move,
  :animator => Animator,
  :validator => Validator,
  :piece => Piece,
  :players => [:white, :black]

Game.add(:chess, Game.extend :chess5x5,
  :size => Point.new(5, 5))
