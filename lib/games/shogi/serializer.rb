module Shogi

class Serializer
  def initialize(rep, validator_factory, 
                 move_factory, piece_factory, notation)
    @rep = rep
    @validator = validator_factory
    @move = move_factory
    @piece = piece_factory
    @notation = notation
  end
  
  def serialize(move, ref)
    case @rep
    when :simple
      dst = @notation.point_to_coord(move.dst)
      result = if move.dropped
        @piece.symbol(move.dropped.type) + '*' + dst
      else
        @notation.point_to_coord(move.src) + dst
      end
      result += '+' if move.promote?
      result
    when :compact
      compact move, ref, lambda{|t| @piece.symbol(t) }
    when :decorated
      compact move, ref, lambda{|t| "{#{t.to_s}}" }
    end
  end
  
  def deserialize(s, ref)
    notation = @notation.read(s)
    read_notation ref, notation if notation
  end
  
  def compact(move, ref, sym)
    result = nil
    if move.dropped
      result = sym[move.dropped.type] + '*' + 
      @notation.point_to_coord(move.dst)
    else
      piece = ref.board[move.src]
      
      capture_square = ref.capture_square(move)
      captured = ref.board[capture_square]
    
      result = sym[piece.type]
      notation = minimal_notation ref,
        :src => move.src,
        :dst => move.dst,
        :type => piece.type,
        :promote => move.promote?
      
      result += @notation.point_to_coord(notation[:src]) if notation[:src]
      result += (captured ? 'x' : '-')
      result += @notation.point_to_coord(notation[:dst])
      result
    end
    
    if move.promote?
      result += '+'
    else
      validate = @validator.new(ref)
      alt = @move.new(move.src, move.dst, :promote => true)
      if validate[alt]
        result += '='
      end
    end
    
    result
  end
  
  def read_notation(ref, san)
    candidate = nil
    validate = @validator.new(ref)

    if san[:src]
      mv = @move.new(san[:src], san[:dst], :promote => san[:promote])
      mv if validate[mv]
    elsif san[:drop]
      mv = @move.drop(@piece.new(ref.turn, san[:type]), san[:dst])
      mv if validate[mv]
    else
      ref.board.each_square do |p|
        mv = @move.new(p, san[:dst], :promote => san[:promote])
        piece = ref.board[p]
        if piece and 
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
  
  def minimal_notation(ref, notation)
    @notation.each_alternative(notation) do |alternative|
      return alternative if read_notation(ref, alternative)
    end
    
    notation
  end
end

end
