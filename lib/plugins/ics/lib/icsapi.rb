# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module ICS

class ICSApi
  PIECES = {
    'r' => :rook,
    'n' => :knight,
    'b' => :bishop,
    'q' => :queen,
    'k' => :king,
    'p' => :pawn }

  def initialize(game)
    @game = game
  end

  def new_state(opts)
    state = @game.state.new
    state.turn = opts[:turn]
    state.en_passant_square = 
      if opts[:en_passant] != -1
        Point.new(opts[:en_passant], 
                  state.turn == :white ? 
                  state.board.size.y - 3 : 2)
      end
    state.castling_rights.cancel_king(:white) unless opts[:wk_castling]
    state.castling_rights.cancel_queen(:white) unless opts[:wq_castling]
    state.castling_rights.cancel_king(:black) unless opts[:bk_castling]
    state.castling_rights.cancel_queen(:black) unless opts[:bq_castling]
    state
  end

  def new_piece(p)
    return nil if p == '-'
    color = p =~ /[a-z]/ ? :black : :white
    type = PIECES[p.downcase]
    @game.piece.new(color, type)
  end
  
  def same_state(state1, state2)
    state1.board == state2.board &&
    state1.turn == state2.turn
  end
end

end
