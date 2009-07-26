# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require_bundle 'chess', 'validator'

module Crazyhouse

class Validator < Chess::Validator
  def validate(move, target = nil)
    piece = move.dropped
    if piece
      return false unless @state.board.valid?(move.dst)
      return false unless piece.color == @state.turn
      return false unless @state.pool(piece.color).has_piece?(piece)
      return false if @state.board[move.dst]
      if piece.type == :pawn
        # pawns cannot be dropped on the last rank
        return false if 
          move.dst.y == @state.row(@state.board.size.y - 1, piece.color)
      end
    else
      return false unless proper?(move)
      piece = @state.board[move.src]
      return false unless check_pseudolegality(piece, target, move)
      move.promotion = nil unless move.type == :promotion
    end
    
    @state.try(move) do |tmp|
      validator = self.class.new(tmp)
      legal = validator.check_legality(piece, target, move)
      return false unless legal
    end
    
    true
  end
end

end
