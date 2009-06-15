require 'games/validable'
require 'point'

module Chess
  class Move
    include Validable
    attr_reader :src, :dst
    attr_accessor :type, :promotion
    
    def initialize(src, dst, opts = {})
      @src = src
      @dst = dst
      @promotion = opts[:promotion]
    end

    def delta
      dst - src
    end
    
    def range
      PointRange.new(src, dst)
    end
    
    def to_s
      "#{src} -> #{dst}"
    end
    
    def == other
      other and @src == other.src and 
      @dst == other.dst and @promotion == other.promotion and
      @type == other.type
    end
  end
end
