require 'qtutils'

class Item < Qt::GraphicsPixmapItem
  attr_reader :name, :item
  attr_reader :opacity
  
  # name is whatever information the caller needs
  # to recreate this piece with a different size
  # 
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

module ItemUtils
  BACKGROUND_ZVALUE = -10
  TEMP_ZVALUE = 10
  
  def create_item(key, pix, opts = {})
    name = opts[:name] || key.to_s
    item = Item.new(name, pix, self, scene)
    item.pos = opts[:pos] || Qt::PointF.new(0, 0)
    item.z_value = opts[:z] || 0
    item.visible = false if opts[:hidden]
    item
  end
  
  def destroy_item(item)
    scene.remove_item item
  end
  
  def raise(item)
    item.z_value = TEMP_ZVALUE
  end
  
  def lower(item)
    item.z_value = 0
  end
end
