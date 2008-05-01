class ChessState
  attr_reader :board
  
  def initialize(board)
    @board = board
  end
  
  def setup
    setup_pawns
    setup_pieces
  end
  
  def setup_pawns
    # place pawns
    (0...@board.size.x).each do |i|
      each_color do |color|
        @board[Point.new(i, row(1, color))] = ChessPiece.new(color, :pawn)
      end
    end
  end
  
  def setup_pieces
    [:white, :black].each do |color|
      y = row(0, color)
      [:rook, :night, :bishop, :queen, :king, :bishop, :night, :rook].each_with_index do |type, x|
        @board[Point.new(x, y)] = ChessPiece.new(color, type)
      end
    end
  end
  
  def row(i, color)
    color == :white ? @board.size.y - 1 - i : i
  end
  
  def each_color
    yield :white
    yield :black
  end
end
