require 'games/state_base'
require 'point'

module Shogi
  class State < StateBase
    def initialize(board, pool_factory, move_factory, piece_factory)
      super(board, move_factory, piece_factory)
      @pools = to_enum(:each_color).inject({}) do |res, c|
        res[c] = pool_factory.new
        res
      end
      @turn = :black
    end
    
    def initialize_copy(other)
      super
      @pools = to_enum(:each_color).inject({}) do |res, c|
        res[c] = other.pool(c).dup
        res
      end
    end
    
    def pool(color)
      @pools[color]
    end
    
    def setup
      each_color do |color|
        (0...@board.size.x).each do |i|
          @board[Point.new(i, row(2, color))] = piece_factory.new(color, :pawn)
        end
        
        r = row(0, color)
        set_piece = lambda do |x, type|
          @board[Point.new(x, r)] = piece_factory.new(color, type)
        end
        set_piece[0, :lance]
        set_piece[1, :horse]
        set_piece[2, :silver]
        set_piece[3, :gold]
        set_piece[4, :king]
        set_piece[5, :gold]
        set_piece[6, :silver]
        set_piece[7, :horse]
        set_piece[8, :lance]
        
        r = row(1, color)
        @board[Point.new(r, r)] = piece_factory.new(color, :rook)
        @board[Point.new(@board.size.x - r - 1, r)] = piece_factory.new(color, :bishop)
      end
    end
    
    def each_color(&blk)
      yield :black
      yield :white
    end
    
    def row(i, color)
      color == :black ? @board.size.y - 1 - i : i
    end
    
    def opposite_color(color)
      color == :black ? :white : :black
    end
    
    def direction(color)
      Point.new(0, color == :black ? -1 : 1)
    end
    
    def perform!(move)
      if move.dropped
        pool(turn).remove(move.dropped)
        board[move.dst] = move.dropped
      else
        captured = basic_move(move)
        if move.promote?
          board[move.dst] = promoted(board[move.dst])
        end
        if captured
          piece = piece_factory.new(turn, captured.type)
          pool(turn).add(demoted(piece))
        end
      end
      switch_turn!
    end
    
    def switch_turn!
      @turn = opposite_color(@turn)
    end
    
    def in_promotion_zone?(p, color)
      (row(6, color) <=> p.y) != (color == :black ? -1 : 1)
    end
    
    def promoted(piece)
      piece_factory.new(
        piece.color, 
        ('promoted_' + piece.type.to_s).to_sym)
    end
    
    def demoted(piece)
      piece_factory.new(
        piece.color,
        piece.type.to_s.gsub(/^promoted_/, '').to_sym)
    end
    
    def promoted_type?(type)
      type.to_s =~ /^promoted_/
    end
    
    def promoted?(piece)
      promoted_type? piece.type
    end
  end
end
