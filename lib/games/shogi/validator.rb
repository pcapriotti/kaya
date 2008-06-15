require 'games/validator_base'

module Shogi
  class Validator < ValidatorBase
    def initialize(state)
      super
    end
    
    def [](move, target = nil)
      return false unless @state.board.valid? move.src
      return false unless @state.board.valid? move.dst
      
      piece = @state.board[move.src]
      return false unless piece and piece.color == @state.turn
      
      return false unless check_pseudolegality(piece, target, move)
      
      @state.try(move) do |tmp|
        validator = self.class.new(tmp)
        legal = validator.check_legality(piece, target, move)
        return false unless legal
      end
      
      true
    end
    
    def validate_pawn(piece, target, move)
      move.delta == @state.direction(piece.color)
    end
    
    def each_move(src, dst, target)
      piece = @state.board[src]
      if piece
        moves = [@state.new_move(src, dst)]
        if @state.in_promotion_zone?(dst, piece.color)
          moves << @state.new_move(src, dst, :promotion => true)
        end
        moves.each do |m|
          yield m if check_pseudolegality(piece, target, m)
        end
      end
    end
  end
end
