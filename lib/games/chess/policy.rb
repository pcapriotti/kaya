module Chess
  class Policy
    def initialize(move_factory)
      @move_factory = move_factory
    end
    
    def movable?(state, p)
      piece = state.board[p]
      piece && piece.color == state.turn
    end
    
    def droppable?(state, color, index)
      color == state.turn
    end
    
    def new_move(state, src, dst, opts = {})
      @move_factory.new(src, dst, opts.merge(:promotion => :queen))
    end
  end
end
