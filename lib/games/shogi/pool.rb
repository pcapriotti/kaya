module Shogi
  class Pool
    attr_reader :pieces
  
    def initialize
      @pieces = Hash.new(0)
    end

    def initialize_copy(other)
      @pieces = other.pieces.dup
    end

    def has_piece?(piece)
      @pieces[piece] > 0
    end
    
    def add(piece)
      @pieces[piece] += 1
    end
    
    def remove(piece)
      @pieces[piece] -= 1
      @pieces.delete(piece) if @pieces[piece] <= 0
    end
    
    def empty?
      @pieces.empty?
    end
    
    def size
      @pieces.values.inject(0, &:+)
    end    
  end
end
