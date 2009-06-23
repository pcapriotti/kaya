require 'qtutils'
require 'plugins/svg_theme'

class CelticTheme < SvgTheme
  include Plugin
  plugin :name => 'Celtic',
         :keywords => %w(chess pieces)

  def initialize(opts = {})
    super(opts)
  end

  def filename
    File.join(File.dirname(__FILE__), 'celtic.svg')
  end
end
