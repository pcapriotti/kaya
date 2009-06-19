require 'qtutils'
require 'themes/theme'
require 'themes/shadow'

class ShogiTheme
  include Theme
  include Shadower
  
  BASE_DIR = File.dirname(__FILE__)
  TYPES = { :knight => 'n' }
  NUDE_TILE = File.join(BASE_DIR, 'nude_tile.svg')
  RATIOS = {
    :king => 1.0,
    :rook => 0.96,
    :bishop => 0.93,
    :gold => 0.9,
    :silver => 0.9,
    :knight => 0.86,
    :lance => 0.83,
    :pawn => 0.8 }

  theme :name => 'Shogi',
        :keywords => %w(shogi pieces)

  def initialize(opts = {})
    @loader = lambda do |piece, size|
      tile = Qt::SvgRenderer.new(NUDE_TILE)
      kanji = Qt::SvgRenderer.new(filename(piece))
      ratio = RATIOS[piece.type] || 0.9
      img = Qt::Image.painted(size) do |p|
        p.scale(ratio, ratio)
        p.translate(size * (1 - ratio) / 2)
        if piece.color == :white
          p.translate(size)
          p.rotate(180)
        end
        tile.render(p)
        kanji.render(p)
      end
    end
    if opts.has_key? :shadow
      @loader = with_shadow(@loader)
    end
  end

  def pixmap(piece, size)
    @loader[piece, size].to_pix
  end
  
  def filename(piece)
    color = piece.color.to_s[0, 1]
#     type = TYPES[piece.type] || piece.type.to_s[0, 1]
    name = piece.type.to_s + ".svg"
    File.join(BASE_DIR, name)
  end
end
