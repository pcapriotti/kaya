class Board < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10

  def initialize(scene, theme, state)
    super(nil, scene)
    @scene = scene
    @theme = theme
    @state = state
    @items = []
  end
  
  def on_resize(rect)
    @items.each {|item| @scene.remove_item(item) }
    @items = []
    
    board = @state.board
    side = [rect.width / board.size.x, rect.height / board.size.y].min.to_i
    unit = Qt::PointF.new(side, side)
    base = Qt::PointF.new((rect.width - side * board.size.x) / 2.0,
                          (rect.height - side * board.size.y) / 2.0)

    self.pos = base
    
    board.each_square do |p|
      piece = board[p]
      if piece
        add_item @theme.pieces.pixmap(piece, unit), 
                 :pos => Qt::PointF.new(side * p.x, side * p.y)
      end
    end
    
    add_item @theme.background.pixmap(unit), :z => BACKGROUND_ZVALUE
  end
  
  def add_item(pix, opts = {})
    @items << pix.to_item(scene).tap do |item|
      item.parent_item = self
      item.pos = opts[:pos] || Qt::PointF.new(0, 0)
      item.z_value = opts[:z] || 0
    end
  end
end
