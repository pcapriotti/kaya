require 'qtutils'
require 'themes/theme'

module SvgTheme
  include Theme

  def initialize(opts)
  end

  def pixmap(piece, size)
    Qt::Pixmap.from_renderer(size, renderer, piece_id(piece))
  end
  
  def renderer
    @renderer ||= create_renderer
  end
  
  def create_renderer
    Qt::SvgRenderer.new(filename)
  end
  
  def piece_id(piece)
    piece.color.to_s.capitalize + piece.type.to_s.capitalize
  end
end
