require 'animation_field'

class Board < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10

  attr_reader :scene, :items

  def initialize(scene, theme, game)
    super(nil, scene)
    @scene = scene
    @theme = theme
    @items = {}
    
    @game = game
    
    @state = @game.new_state
    @state.setup
    
    @animator = @game.new_animator(self)
    
    @field = AnimationField.new(20)
  end
  
  def on_resize(rect)
    @items.keys.each {|key| remove_item(key) }
    
    board = @state.board
    side = [rect.width / board.size.x, rect.height / board.size.y].min.to_i
    @unit = Qt::PointF.new(side, side)
    base = Qt::PointF.new((rect.width - side * board.size.x) / 2.0,
                          (rect.height - side * board.size.y) / 2.0)

    self.pos = base
    
    board.each_square do |p|
      piece = board[p]
      add_piece(p, piece) if piece
    end
    
    add_item :background, 
             @theme.background.pixmap(@unit), 
             :z => BACKGROUND_ZVALUE
  end
  
  def add_item(key, pix, opts = {})
    remove_item key
    
    item = Qt::GraphicsPixmapItem.new(pix, self, scene)
    item.pos = opts[:pos] || Qt::PointF.new(0, 0)
    item.z_value = opts[:z] || 0
    
    @items[key] = Item.new(opts[:name] || key.to_s, item)
  end
  
  def add_piece(p, piece)
    add_item p, @theme.pieces.pixmap(piece, @unit),
             :pos => Qt::PointF.new(@unit.x * p.x, @unit.y * p.y),
             :name => piece.name
  end
  
  def remove_item(key)
    if @items[key]
      @scene.remove_item @items[key].item
      @items[key] = nil
    end
  end
  
  def mousePressEvent(e)
    p = to_logical(e.pos)
    
    if @action
      move = @game.new_move(@action, p)
      perform! move if @state.validate!(move)
      
      @action = nil
    elsif @game.policy.movable?(@state, p)
      @action = p
    end
    
    puts "selection = #{@action}"
  end
  
  def perform!(move)
    @state.perform! move
    animation = @animator.forward @state, move
    @field.run animation
  end
  
  def to_logical(p)
    Point.new((p.x.to_f / @unit.x).floor,
              (p.y.to_f / @unit.y).floor)
  end
  
  def to_real(p)
    res = Qt::PointF.new(p.x * @unit.x, p.y * @unit.y)
    puts "to_real(#{p}) = #{res}"
    res
  end
end
