require 'item'

class Pool < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10
  
  include Observable
  include ItemBag
  
  attr_reader :layout_item
  attr_reader :items
  
  def initialize(scene, theme, game, pool, field)
    super(nil, scene)
    @scene = scene
    @theme = theme
    @game = game
    @pool = pool
    @field = field
    
    @items = {}
  end
  
  def set_geometry(rect)
    self.pos = rect.top_left
#     unit = Qt::PointF.new(rect.width, rect.height)
#     add_item :background,
#              @theme.pieces.pixmap(@game.piece.new(:black, :promoted_rook), unit), 
#              :z => BACKGROUND_ZVALUE
  end
  
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
end
