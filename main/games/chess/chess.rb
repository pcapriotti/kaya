require 'games/chess/state'
require 'games/chess/move'
require 'games/chess/board'
require 'games/chess/policy'
require 'games/chess/animator'
require 'games/chess/validator'

module Chess
  class Game
    attr_reader :size, :policy
    
    def initialize(opts = Chess::chess_opts)
      @opts = opts
      @policy = @opts[:policy].new
      @size = @opts[:size]
    end
    
    def new_state
      @opts[:state].new(new_board)
    end
    
    def new_board
      @opts[:board].new(size)
    end
    
    def new_move(src, dst, opts = {})
      @opts[:move].new(src, dst, opts)
    end
    
    def new_animator(board)
      @opts[:animator].new(board)
    end
    
    def new_validator(state)
      @opts[:validator].new(state)
    end
  end
  
  def self.chess_opts
    {
      :size => Point.new(8, 8),
      :state => State,
      :board => Board,
      :policy => Policy,
      :move => Move,
      :animator => Animator,
      :validator => Validator
    }
  end
end
