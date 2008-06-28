require 'qtutils'
require 'themes/theme'

class FantasyTheme
  include Theme
  BASE_DIR = File.dirname(__FILE__)
  TYPES = { :knight => 'n' }

  theme :name => 'Shogi'

  def pixmap(piece, size)
    Qt::Pixmap.from_svg(size, filename(piece))
  end
  
  def filename(piece)
    color = piece.color.to_s[0, 1]
#     type = TYPES[piece.type] || piece.type.to_s[0, 1]
    name = piece.type.to_s + ".svg"
    File.join(BASE_DIR, name)
  end
end
