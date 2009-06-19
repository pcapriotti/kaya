require 'qtutils'
require 'themes/svg_theme'

class FantasyTheme < SvgTheme
  include Theme
  theme :name => 'Fantasy',
        :keywords => %w(chess pieces)

  def initialize(opts = {})
    super(opts)
  end

  def filename
    File.join(File.dirname(__FILE__), 'fantasy.svg')
  end
end
