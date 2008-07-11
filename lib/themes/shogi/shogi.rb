require 'qtutils'
require 'themes/theme'

class FantasyTheme
  include Theme
  BASE_DIR = File.dirname(__FILE__)
  TYPES = { :knight => 'n' }
  NUDE_TILE = File.join(BASE_DIR, 'nude_tile.svg')

  theme :name => 'Shogi'

  def pixmap(piece, size)
    tile = Qt::SvgRenderer.new(NUDE_TILE)
    kanji = Qt::SvgRenderer.new(filename(piece))
    img = Qt::Image.painted(size) do |p|
      if piece.color == :white
        p.translate(size)
        p.rotate(180)
      end
      kanji.render(p)
      tile.render(p)
    end
    img.to_pix
  end
  
  def filename(piece)
    color = piece.color.to_s[0, 1]
#     type = TYPES[piece.type] || piece.type.to_s[0, 1]
    name = piece.type.to_s + ".svg"
    File.join(BASE_DIR, name)
  end
end
