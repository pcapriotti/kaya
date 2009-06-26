module Chess
  class Policy
    attr_accessor :promotion
    
    def initialize(move_factory)
      @move_factory = move_factory
      @promotion = :queen
    end
    
    def movable?(state, p)
      piece = state.board[p]
      piece && piece.color == state.turn
    end
    
    def droppable?(state, color, index)
      color == state.turn
    end
    
    def new_move(state, src, dst, opts = {})
      @move_factory.new(src, dst, opts.merge(:promotion => @promotion))
    end
  end
end
