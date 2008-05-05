module Chess
  class Validator
    def initialize(state)
      @state = state
    end
  
    def [](move)
      return false unless @state.board.valid? move.src
      return false unless @state.board.valid? move.dst
      return false if move.dst == move.src
      
      piece = @state.board[move.src]
      return false unless piece and piece.color == @state.turn
      
      target = @state.board[move.dst]
      return false if piece.same_color_of(target)
    
      m = "validate_#{piece.type}"
      if respond_to? m
        send(m, piece, target, move)
      else
        false
      end
    end
    
    def validate_pawn(piece, target, move)
      dir = @state.direction(piece.color)
      if target
        move.delta.y == dir.y and
        move.delta.x.abs == 1
      else
        case move.delta.y
        when dir.y
          move.delta.x == 0
        when dir.y * 2
          move.src.y == @state.row(1, piece.color) and 
          move.delta.x == 0 and 
          not @state.board[move.src + dir]
        else
          false
        end
      end
    end
    
    def validate_king(piece, target, move)
      move.delta.x.abs <= 1 and 
      move.delta.y.abs <= 1
    end
  end
end
