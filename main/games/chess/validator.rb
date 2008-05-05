module Chess
  class Validator
    def initialize(state)
      @state = state
    end
  
    def [](move)
      break false unless @state.board.valid? move.src
      break false unless @state.board.valid? move.dst
      
      piece = @state.board[move.src]
      break false unless piece and piece.color == @state.turn
      target = @state.board[move.dst]
    
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
        target.color != piece.color and
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
  end
end
