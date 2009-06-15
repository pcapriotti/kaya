require 'games/validator_base'

module Shogi
  class Validator < ValidatorBase
    def initialize(state)
      super
    end
    
    def [](move, target = nil)
      return false unless move.dropped || @state.board.valid?(move.src)
      return false unless @state.board.valid? move.dst
      
      piece = move.dropped
      if piece
        return false unless piece.color == @state.turn
        return false unless @state.pool(piece.color).has_piece?(piece)
      else
        piece = @state.board[move.src]
        return false unless piece and piece.color == @state.turn
        return false unless check_pseudolegality(piece, target, move)
      end
      
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
    
    def validate_lance(piece, target, move)
      move.delta.x == 0 and
      move.delta.y.unit == @state.direction(piece.color).y and
      @state.board.clear_path? move.range
    end
    
    def validate_horse(piece, target, move)
      move.delta.x.abs == 1 and
      move.delta.y == 2 * @state.direction(piece.color).y
    end
    
    def validate_silver(piece, target, move)
      dir = @state.direction(piece.color).y
      move.delta.y == dir or
      (move.delta.x.abs == 1 and move.delta.y == -dir)
    end
    
    def validate_gold(piece, target, move)
      dir = @state.direction(piece.color).y
      move.delta.y == dir or
      move.delta.x.abs + move.delta.y.abs == 1
    end
    
    def validate_king(piece, target, move)
      move.delta.x.abs <= 1 and
      move.delta.y.abs <= 1
    end
    
    def each_move(src, dst, target)
      piece = @state.board[src]
      if piece
        moves = [@state.move_factory.new(src, dst)]
        if @state.in_promotion_zone?(dst, piece.color)
          moves << @state.move_factory.new(src, dst, :promotion => true)
        end
        moves.each do |m|
          yield m if check_pseudolegality(piece, target, m)
        end
      end
    end
  end
end
