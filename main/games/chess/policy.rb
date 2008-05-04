module Chess
  class Policy
    def movable?(state, p)
      piece = state.board[p]
      piece && piece.color == state.turn
    end
  end
end
