require 'animation_field'
require 'board/square_tag.rb'

class Board < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10
  
  extend TaggableSquares

  attr_reader :scene, :items, :to_logical, :to_real
  square_tag :selection

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
    
    name = opts[:name] || key.to_s
    item = Item.new(name, pix, self, scene)
    item.pos = opts[:pos] || Qt::PointF.new(0, 0)
    item.z_value = opts[:z] || 0
    @items[key] = item
  end
  
  def add_piece(p, piece)
    add_item p, @theme.pieces.pixmap(piece, @unit),
             :pos => Qt::PointF.new(@unit.x * p.x, @unit.y * p.y),
             :name => piece.name
  end
  
  def remove_item(key, *args)
    if @items[key]
      @scene.remove_item @items[key] unless args.include? :keep
      removed = @items[key]
      @items[key] = nil
      removed
    end
  end
  
  def move_item(src, dst)
    remove_item dst
    @items[dst] = @items[src]
    @items[src] = nil
    @items[dst]
  end
  
  def mousePressEvent(e)
    p = to_logical(e.pos)
    
    if selection
      move = @game.new_move(selection, p)
      perform! move if @state.validate!(move)
      
      self.selection = nil
    elsif @game.policy.movable?(@state, p)
      self.selection = p
    end
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
    res
  end
end
