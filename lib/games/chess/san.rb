require 'strscan'

module Chess

class SAN
  def initialize(piece_factory, size)
    @piece_factory = piece_factory
    @size = size
  end

  def from_scanner(scanner)
    if scanner.scan(/([PRNBKQ])?([a-wyzA-Z]?\d*|x\d+)([-x@])?([a-zA-Z]\d+)(=?([RNBKQrnbkq]))?[+#]?[\?!]*/)
      { :type => @piece_factory.type_from_symbol(scanner[1] || 'P'),
        :drop => drop = scanner[3] == '@',
        :src => (Point.from_coord(scanner[2], @size.y) unless drop),
        :dst => Point.from_coord(scanner[4], @size.y),
        :promotion => (@piece_factory.type_from_symbol(scanner[6]) if scanner[6]) }
    elsif scanner.scan(/^[oO0]-?[oO0]-?[oO0][+#]?/)
      { :castling => :queen }
    elsif scanner.scan(/[oO0]-?[oO0][+#]?/)
      { :castling => :king }
    else
      scanner.scan(/none/) # possibly consume 'none'
      { }
    end
  end
  
  def from_s(str)
    from_scanner(StringScanner.new(str))
  end
  
  def read(input)
    case input
    when String
      from_s(input)
    else
      from_scanner(input)
    end
  end
  
  def each_alternative(san)
    # try notation without starting point
    yield san.dup.tap{|s| s[:src] = nil }

    # add row indication
    yield san.dup.tap{|s| s[:src] = Point.new(s[:src].x, nil) }
    
    # add column indication
    yield san.dup.tap{|s| s[:src] = Point.new(nil, s[:src].y) }
  end
end

end
