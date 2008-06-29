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
  end
end
