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
require 'games/game_actions'

module Chess

class Game
  include Plugin
  include GameActions
  
  plugin :name => 'Chess',
         :id => :chess,
         :interface => :game,
         :keywords => %w(chess)
         
  attr_reader :size, :policy, :state, :board, :move,
              :animator, :validator, :piece, :players,
              :types, :serializer, :game_writer,
              :game_extensions, :notation
              
  def initialize
    @size = Point.new(8, 8)
    @state_component = State
    @state = Factory.new(State) { State.new(board.new, move, piece) }
    @board = Factory.new(Board) { Board.new(size) }
    @move = Move
    @animator = Animator
    @validator = Validator
    @piece = Piece
    @policy = Factory.new { Policy.new(Move) }
    @players = [:white, :black]
    @types = [:pawn, :knight,:bishop, :rook, :queen, :king]
    @notation = SAN.new(piece, size)
    @serializer = Factory.new(Serializer) {|rep| 
      Serializer.new(rep, validator, move, piece, notation) }
    @keywords = %w(chess)

    @game_writer = PGN.new(serializer.new(:compact), state)
    @game_extensions = %w(pgn)
    
    action :promote_to_queen,
           :text => 'Promote to &Queen' do |policy| 
      policy.promotion = :queen
    end
    action :promote_to_rook, 
           :text => 'Promote to &Rook' do |policy| 
      policy.promotion = :rook
    end
    action :promote_to_bishop, 
           :text => 'Promote to &Bishop' do |policy| 
      policy.promotion = :bishop
    end
    action :promote_to_knight, 
           :text => 'Promote to &Knight' do |policy| 
      policy.promotion = :knight
    end
  end
  
  def game_reader
    @game_writer
  end
  
  def actions(parent, collection, policy)
    acts = super
    group = Qt::ActionGroup.new(parent)
    group.exclusive = true
    acts.each do |act| 
      act.checkable = true
      act.action_group = group
    end
    acts.first.checked = true
    acts
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
