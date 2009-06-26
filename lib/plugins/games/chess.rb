require 'games/games'
require 'games/chess/state'
require 'games/chess/move'
require 'games/chess/board'
require 'games/chess/policy'
require 'games/chess/animator'
require 'games/chess/validator'
require 'games/chess/serializer'
require 'games/chess/pgn'
require 'plugins/plugin'

module Chess

class Game
  include Plugin
  
  plugin :name => 'Chess',
         :id => :chess,
         :interface => :game,
         :keywords => %w(chess)
         
  attr_reader :size, :policy, :state, :board, :move,
              :animator, :validator, :piece, :players,
              :types, :serializer, :game_writer,
              :game_extensions
              
  def initialize
    @size = Point.new(8, 8)
    @policy = Policy.new(Move)
    @state_component = State
    @state = Factory.new(State) { State.new(board.new, move, piece) }
    @board = Factory.new(Board) { Board.new(size) }
    @move = Move
    @animator = Animator
    @validator = Validator
    @piece = Piece
    @players = [:white, :black]
    @types = [:pawn, :knight,:bishop, :rook, :queen, :king]
    @serializer = Factory.new(Serializer) {|rep| 
      Serializer.new(rep, validator, move, piece) }
    @keywords = %w(chess)

    @game_writer = PGN.new(serializer.new(:compact), state)
    @game_extensions = %w(pgn)
  end
  
  def game_reader
    @game_writer
  end
end

end

module Chess5x5

class Game < Chess::Game
  plugin :name => 'Chess 5x5',
         :id => :chess5x5,
         :interface => :game,
         :keywords => %w(chess)
  
  def initialize
    super
    @size = Point.new(5, 5)
    @game_extensions = []
  end
  
end

end
