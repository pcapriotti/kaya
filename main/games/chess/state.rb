require 'games/chess/piece'

module Chess
  class State
    attr_reader :board
    attr_accessor :turn
    
    def initialize(board)
      @board = board
      @turn = :white
    end
    
    def setup
      setup_pawns
      setup_pieces
    end
    
    def setup_pawns
      # place pawns
      (0...@board.size.x).each do |i|
        each_color do |color|
          @board[Point.new(i, row(1, color))] = Chess::Piece.new(color, :pawn)
        end
      end
    end
    
    def setup_pieces
      [:white, :black].each do |color|
        y = row(0, color)
        [:rook, :night, :bishop, :queen, :king, :bishop, :night, :rook].each_with_index do |type, x|
          @board[Point.new(x, y)] = Chess::Piece.new(color, type)
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
    
    def validate!(move)
      move.validate do |move|
        true
      end
    end
    
    def perform!(move)
      capture_on! move.dst
      @board[move.dst] = @board[move.src]
      @board[move.src] = nil
      switch_turn!
    end
    
    def capture_on!(p)
      @board[p] = nil
    end
    
    def switch_turn!
      self.turn = opposite_turn turn
    end
    
    def opposite_turn(t)
      t == :white ? :black : :white
    end
    
    def to_s
      board.to_s + "\nturn = #{turn}"
    end
  end
end
