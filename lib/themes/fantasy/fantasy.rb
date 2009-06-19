require 'qtutils'
require 'themes/svg_theme'

class FantasyTheme
  include SvgTheme
  
  theme :name => 'Fantasy',
        :keywords => %w(chess pieces)
  
  def filename
    File.join(File.dirname(__FILE__), 'fantasy.svg')
  end
end
