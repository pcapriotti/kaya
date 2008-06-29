require 'games/chess/chess'
require 'games/shogi/state'
require 'games/chess/board'
require 'games/chess/policy'
require 'games/shogi/move'
require 'games/chess/animator'
require 'games/shogi/validator'
require 'games/chess/piece'

module Shogi
  class Game < Chess::Game
    def self.opts
      {
        :size => Point.new(9, 9),
        :state => State,
        :board => Chess::Board,
        :policy => Chess::Policy,
        :move => Move,
        :animator => Chess::Animator,
        :validator => Shogi::Validator,
        :piece => Chess::Piece
      }
    end
  end
end
