module Chess
  class Policy
    def initialize(move_factory)
      @move_factory = move_factory
    end
    
    def movable?(state, p)
      piece = state.board[p]
      piece && piece.color == state.turn
    end
    
    def new_move(state, src, dst)
      @move_factory.new(src, dst, :promotion => :queen)
    end
  end
end
