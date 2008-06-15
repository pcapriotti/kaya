require 'games/state_base'
require 'point'

module Shogi
  class State
    include StateBase
    attr_reader :turn, :board
  
    def initialize(board, move_factory, piece_factory)
      @board = board
      @move_factory = move_factory
      @piece_factory = piece_factory
      @turn = :black
    end
    
    def setup
      each_color do |color|
        (0...@board.size.x).each do |i|
          @board[Point.new(i, row(1, color))] = new_piece(color, :pawn)
        end
        
        r = row(0, color)
        set_piece = lambda do |x, type|
          @board[Point.new(x, r)] = new_piece(color, type)
        end
        set_piece[0, :lance]
        set_piece[1, :knight]
        set_piece[2, :silver]
        set_piece[3, :gold]
        set_piece[4, :king]
        set_piece[5, :gold]
        set_piece[6, :silver]
        set_piece[7, :knight]
        set_piece[8, :lance]
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
  end
end
