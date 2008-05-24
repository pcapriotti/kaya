require 'qtutils'

class Item < Qt::GraphicsPixmapItem
  attr_reader :name, :item
  attr_reader :opacity
  
  def initialize(name, pixmap, parent, scene)
    super pixmap, parent, scene
    @name = name
    @opacity = 1.0
  end
  
  def paint(p, options, widget)
    p.saving do |p|
      p.opacity = @opacity
      super p, options, widget
    end
  end
  
  def opacity=(value)
    @opacity = value
    update
  end
  
  def remove
    scene.remove_item self
  end
end
