require 'qtutils'
require 'themes/svg_theme'

class CelticTheme
  include SvgTheme
  
  theme :name => 'Celtic'
  
  def filename
    File.join(File.dirname(__FILE__), 'celtic.svg')
  end
end
