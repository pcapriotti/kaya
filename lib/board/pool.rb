require 'item'

class Pool < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10
  
  include Observable
  include ItemUtils
  
  attr_reader :rect
  attr_reader :scene
  
  def initialize(scene, theme, game)
    super(nil, scene)
    @scene = scene
    @scene.add_element(self)
    
    @theme = theme
    @game = game
    
    @items = []
    @size = Point.new(3, 5)
  end
  
  def redraw
    pieces = @items.map do |item|
      destroy_item(item)
      item.name
    end
    
    pieces.each_with_index do |piece, index|
      add_piece(index, piece)
    end
  end
  
  def set_geometry(rect)
    @rect = rect
    
    self.pos = @rect.top_left.to_f
    
    @unit = (@rect.width / @size.x).floor
    redraw
  end
  
  def add_piece(index, piece)
    item = create_piece piece, 
      @theme.pieces.pixmap(piece, Qt::Point.new(@unit, @unit)),
      :pos => to_real(index)
    @items.insert(index, item)
    
    # TODO shift the other items
    
    item
  end
  
  def on_click(pos)
    index = to_logical(pos)
    puts "index = #{index}"
  end
  
  def to_logical(p)
    result = Point.new((p.x.to_f / @unit).floor,
                       (p.y.to_f / @unit).floor)
    y = result.y
    x = y % 2 == 0 ? result.x : @size.x - result.x - 1
    x + y * @size.x
  end
  
  def to_real(index)
    x = index % @size.x
    y = index / @size.x
    x = @size.x - x - 1 if y % 2 == 1
    
    Qt::PointF.new(x * @unit, y * @unit)
  end
end
