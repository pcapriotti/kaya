require 'strscan'

module Shogi

class Notation
  def initialize(piece_factory, size)
    @piece_factory = piece_factory
    @size = size
  end

  def from_scanner(scanner)
    if scanner.scan(/(\+?[A-Z])(\d[a-z])?([-*x])?(\d[a-z])([+=])?/)
      { :type => @piece_factory.type_from_symbol(scanner[1]),
        :src => point_from_coord(scanner[2]),
        :drop => scanner[3] == '*',
        :dst => point_from_coord(scanner[4]),
        :promote => scanner[5] == '+' }
    end
  end
  
  def from_s(str)
    from_scanner(StringScanner.new(str))
  end
  
  def read(input)
    result = case input
    when String
      from_s(input)
    else
      from_scanner(input)
    end
    result
  end
  
  def each_alternative(notation)
    yield notation.dup.tap{|n| n[:src] = nil }
  end
  
  def point_from_coord(coord)
    if coord =~ /^(\d)([a-z])$/
      Point.new(@size.x - $1.to_i, $2[0] - ?a)
    end
  end
  
  def point_to_coord(p)
    "#{@size.x - p.x}#{(p.y + ?a).chr}"
  end
end

end
