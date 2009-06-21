require 'item'

class Pool < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10
  
  include Observable
  include ItemUtils
  
  attr_reader :rect
  attr_reader :scene
  
  def initialize(scene, theme, game, field)
    super(nil, scene)
    @scene = scene
    @scene.add_element(self)
    
    @theme = theme
    @game = game
    @field = field
    
    @items = []
    @size = Point.new(3, 5)
  end
  
  def redraw
  end
  
  def set_geometry(rect)
    @rect = rect
    
    self.pos = @rect.top_left
    
    @unit = (@rect.width / @size.x).floor
    redraw
  end
  
  def add_piece(piece)
    
  end
  
  def to_logical(p)
  end
  
  def to_real(index)
    x = index % @size.x
    y = index / @size.x
    x = @size.x - x - 1 if y % 2 == 1
    
    Qt::PointF.new(x * @unit, y * @unit)
  end
end
