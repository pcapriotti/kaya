require 'games/chess/san'
require 'point'

module Chess

class Serializer
  include SAN

  def initialize(rep, validator_factory, 
                 move_factory, piece_factory)
    @rep = rep
    @validator = validator_factory
    @move = move_factory
    @piece = piece_factory
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
    ysize = ref.board.size.y
    san = case s
    when String
      SAN.san_from_s(@piece, s, ysize)
    else
      # assume it's a scanner
      SAN.san_from_scanner(@piece, s, ysize)
    end
    read_san ref, san
  end
  
  def read_san(ref, san)
    candidate = nil
    return candidate unless san[:dst] or san[:castling]
    validate = @validator.new(ref)
    
    if san[:castling]
      # find king starting position
      src = Point.new(ref.board.size.x / 2, ref.row(0, ref.turn))
      dst = from + (san[:castling] == :king ? Point(2, 0) : Point(-2, 0))
      king = ref.board.get(src)
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
    result = san.dup

    # try notation without starting point
    result[:src] = nil
    return result if read_san(ref, result)

    # add row indication
    result[:src] = Point.new(san[:src].x, nil)
    return result if read_san(ref, result)
    
    # add column indication
    result[:src] = Point.new(nil, san[:src].y)
    return result if read_san(ref, result)

    # add complete starting point
    result[:src] = san[:src]
    result
  end
end

end