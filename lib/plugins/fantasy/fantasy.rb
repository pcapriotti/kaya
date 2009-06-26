require 'qtutils'
require 'plugins/svg_theme'

class FantasyTheme < SvgTheme
  include Plugin
  plugin :name => 'Fantasy',
         :interface => :pieces,
         :keywords => %w(chess)

  def initialize(opts = {})
    super(opts)
  end

  def filename
    File.join(File.dirname(__FILE__), 'fantasy.svg')
  end
end
