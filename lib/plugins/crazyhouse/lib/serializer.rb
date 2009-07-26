# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require_bundle 'chess', 'serializer'

module Crazyhouse

class Serializer < Chess::Serializer
  def serialize(move, ref)
    if move.dropped
      serialize_drop(move, ref)
    else
      super(move, ref)
    end
  end
  
  def deserialize(s, ref)
    notation = @notation.read(s)
    if notation
      if notation[:drop]
        read_drop_san ref, notation
      else
        read_san ref, notation
      end
    end
  end
  
  def serialize_drop(move, ref)
    sym = case @rep
    when :simple, :compact
      lambda{|t| @piece.symbol(t) }
    when :decorated
      lambda{|t| "{#{t.to_s}}" }
    end
    result = sym[move.dropped.type] + "@"
    result += move.dst.to_coord(ref.board.size.y)
    result
  end
  
  def read_drop_san(ref, notation)
    return nil unless notation[:type]
    return nil unless notation[:dst]
    
    piece = @piece.new(ref.turn, notation[:type])
    @move.drop(piece, notation[:dst])
  end
end

end
