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

class ChessGame
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
    @serializer = lambda {|rep| 
      Serializer.new(rep, validator, move, piece) }
    @keywords = %w(chess)

    @game_writer = PGN.new(serializer.new(:compact), state)
    @game_extensions = %w(pgn)
  end
  
  def game_reader
    @game_writer
  end
end

class Chess5x5Game < ChessGame
  plugin :name => 'Chess 5x5',
         :id => :chess5x5,
         :interface => :game,
         :keywords => %w(chess)
  
  def initialize
    @size = Point.new(5, 5)
  end
end
