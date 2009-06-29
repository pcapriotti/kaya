# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/chess/san'
require 'point'

module Chess

class Serializer
  def initialize(rep, validator_factory, 
                 move_factory, piece_factory, 
                 notation)
    @rep = rep
    @validator = validator_factory
    @move = move_factory
    @piece = piece_factory
    @notation = notation
  end
  
  def serialize(move, ref)
    case @rep
    when :simple
      ysize = ref.board.size.y
      result = move.src.to_coord(ysize) + move.dst.to_coord(ysize)
      result += '=' + @piece.symbol(move.promotion) if move.promotion
      result
    when :compact
      san move, ref, lambda{|t| @piece.symbol(t) }
    when :decorated
      san move, ref, lambda{|t| "{#{t.to_s}}" }
    end
  end
  
  def deserialize(s, ref)
    notation = @notation.read(s)
    read_san ref, notation if notation
  end
  
  def read_san(ref, san)
    candidate = nil
    return candidate unless san[:dst] or san[:castling]
    validate = @validator.new(ref)
    
    if san[:castling]
      # find king starting position
      src = Point.new(ref.board.size.x / 2, ref.row(0, ref.turn))
      dst = src + (san[:castling] == :king ? Point.new(2, 0) : Point.new(-2, 0))
      king = ref.board[src]
      return candidate unless king.type == :king
      candidate = @move.new(src, dst)
      candidate if validate[candidate]
    elsif san[:src] and san[:src].x and san[:src].y
      mv = @move.new(san[:src], san[:dst], :promotion => san[:promotion])
      mv if validate[mv]
    else
      ref.board.each_square do |p|
        mv = @move.new(p, san[:dst], :promotion => san[:promotion])
        piece = ref.board[p]
        if p =~ san[:src] and piece and 
           piece.type == san[:type] and
           piece.color == ref.turn
          if validate[mv]
            if candidate
              # ambiguous!
              return nil
            else
              candidate = mv
            end
          end
        end
      end
      candidate
    end
  end
  
  def san(move, ref, sym)
    piece = ref.board[move.src]
        
    return "" unless piece
    return "0-0" if move.type == :king_side_castling
    return "0-0-0" if move.type == :queen_side_castling  
    
    capture_square = ref.capture_square(move)
    captured = ref.board[capture_square]
    
    result = ""
    ysize = ref.board.size.y
    
    if piece.type == :pawn
      result = if captured
        result = Point.new(move.src.x, nil).to_coord(ysize) + 'x'
      else
        ""
      end
      result += move.dst.to_coord(ysize)
    else
      result = sym[piece.type]
      san = minimal_notation ref,
        :src => move.src,
        :dst => move.dst,
        :type => piece.type
      
      result += san[:src].to_coord(ysize) if san[:src]
      result += 'x' if captured
      result += san[:dst].to_coord(ysize)
    end
    
    if move.promotion
      result += '=' + sym[move.promotion]
    end
    
    result
  end
  
  def minimal_notation(ref, san)
    @notation.each_alternative(san) do |alternative|
      return alternative if read_san(ref, alternative)
    end
    
    san
  end
end

end