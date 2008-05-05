require 'games/validable'

module Chess
  class Move
    include Validable
    attr_reader :src, :dst
    
    def initialize(src, dst)
      @src = src
      @dst = dst
    end
    
    def delta
      dst - src
    end
    
    def capture_square
      dst
    end
    
    def to_s
      "#{src} -> #{dst}"
    end
  end
end
