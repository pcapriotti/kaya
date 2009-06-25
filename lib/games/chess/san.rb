require 'strscan'

module Chess

module SAN
  def self.san_from_scanner(piece_factory, scanner, ysize)
    if scanner.scan(/([PRNBKQ])?([a-wyzA-Z]?\d*|x\d+)([-x@])?([a-zA-Z]\d+)(=?([RNBKQrnbkq]))?[+#]?[\?!]*/)
      drop = scanner[3] == '@'
      { :type => piece_factory.type_from_symbol(scanner[1] || 'P'),
        :drop => drop,
        :src => (Point.from_coord(scanner[2], ysize) unless drop),
        :dst => Point.from_coord(scanner[4], ysize),
        :promotion => (piece_factory.type_from_symbol(scanner[6]) if scanner[6]) }
    elsif scanner.scan(/^[oO0]-?[oO0]-?[oO0][+#]?/)
      { :castling => :queen }
    elsif scanner.scan(/[oO0]-?[oO0][+#]?/)
      { :castling => :king }
    else
      scanner.scan(/none/) # possibly consume 'none'
      { }
    end
  end
  
  def self.san_from_s(piece_factory, str, ysize)
    san_from_scanner(piece_factory, StringScanner.new(str), ysize)
  end
end

end