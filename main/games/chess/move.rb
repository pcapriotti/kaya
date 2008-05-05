require 'games/validable'
require 'point'

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
    
    def range
      PointRange.new(src, dst)
    end
    
    def to_s
      "#{src} -> #{dst}"
    end
  end
end
