require 'qtutils'
require 'themes/svg_theme'

class CelticTheme < SvgTheme
  include Theme
  theme :name => 'Celtic',
        :keywords => %w(chess pieces)

  def initialize(opts = {})
    super(opts)
  end

  def filename
    File.join(File.dirname(__FILE__), 'celtic.svg')
  end
end
