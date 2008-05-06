require 'games/chess/piece'

module Chess
  class State
    attr_reader :board
    attr_accessor :turn, :en_passant_square
    
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
        [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook].each_with_index do |type, x|
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
    
    def perform!(move)
      if move.type == :en_passant_trigger
        self.en_passant_square = move.src + direction(turn)
      else
        self.en_passant_square = nil
      end
      
      if move.type == :en_passant_capture
        capture_on! Point.new(move.dst.x, move.src.y)
      else
        capture_on! move.dst
      end
      
      basic_move move
    end
    
    def basic_move(move)
      @board[move.dst] = @board[move.src]
      @board[move.src] = nil
      switch_turn!
    end
     
    def perform_en_passant_trigger(move)
      self.en_passant_square = move.src + direction(turn)
    end
    
    def perform_en_passant_capture(move)
      capture_on! 
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
    
    def direction(color)
      Point.new(0, color == :white ? -1 : 1)
    end
  end
end
