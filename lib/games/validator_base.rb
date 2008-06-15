class ValidatorBase
  def initialize(state)
    @state = state
  end

  # whether this move satisfies basic conditions
  # for validity
  # 
  def proper?(move)
    return false unless @state.board.valid? move.src
    return false unless @state.board.valid? move.dst
    
    piece = @state.board[move.src]
    return false unless piece and piece.color == @state.turn
    true
  end
  
  def check_legality(piece, target, move)
    king_pos = @state.board.find(@state.new_piece(piece.color, :king))
    if king_pos
      not attacked?(king_pos)
    end
  end
  
  def check_pseudolegality(piece, target, move)
    return false if move.dst == move.src
    
    target ||= @state.board[move.dst]
    return false if piece.same_color_of?(target)
  
    m = "validate_#{piece.type}"
    valid = if respond_to? m
      send(m, piece, target, move)
    end
  end

  def attacked?(dst, target = nil)
    @state.board.to_enum(:each_square).any? do |src|
      to_enum(:each_move, src, dst, target).any? { true }
    end
  end
end
