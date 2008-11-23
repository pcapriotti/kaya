class StateBase
  attr_accessor :turn
  attr_reader :board

  def initialize(board, move_factory, piece_factory)
    @board = board
    @move_factory = move_factory
    @piece_factory = piece_factory
  end
  
  def initialize_copy(other)
    @board = other.board.dup
  end
  
  def new_piece(*args)
    @piece_factory.new(*args)
  end
  
  def new_move(*args)
    @move_factory.new(*args)
  end
  
  def try(move)
    tmp = dup
    tmp.perform! move
    yield tmp
  end
  
  def basic_move(move)
    @board[move.dst] = @board[move.src]
    @board[move.src] = nil
  end
  
  def promote_on!(p, type)
    if @board[p]
      @board[p] = new_piece(@board[p].color, type)
    end
  end
  
  def to_s
    [@board.to_s,
     "turn #{@turn.to_s}"].join("\n")
  end

  def ==(other)
    @board == other.board &&
      @turn == other.turn
  end
end
