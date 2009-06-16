require 'animation_field'
require 'board/square_tag.rb'
require 'observer'
require 'board/point_converter.rb'
require 'item'
require 'board/item_bag'

class Board < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10
  
  extend TaggableSquares
  include Observable
  include PointConverter
  include ItemBag

  attr_reader :scene, :items, :state, :unit, :theme
  square_tag :selection

  def initialize(scene, theme, game, state = nil)
    super(nil, scene)
    @scene = scene
    @theme = theme
    @items = {}
    
    @game = game
    
    @state = state
    unless @state
      @state = @game.state.new
      @state.setup
    end
    
    @animator = @game.animator.new(self)
    
    @field = AnimationField.new(20)
    @flipped = false
  end
  
  def flipped?
    @flipped
  end
  
  def flip!
    @flipped = !@flipped
    redraw
  end
  
  def redraw
    board = @state.board
    @items.keys.each {|key| remove_item(key) }
    board.each_square do |p|
      piece = board[p]
      add_piece(p, piece) if piece
    end
    
    add_item :background, 
             @theme.background.pixmap(@unit), 
             :z => BACKGROUND_ZVALUE
  end
  
  def on_resize(rect)
    board = @state.board
    side = [rect.width / board.size.x, rect.height / board.size.y].min.to_i
    @unit = Qt::PointF.new(side, side)
    base = Qt::PointF.new((rect.width - side * board.size.x) / 2.0,
                          (rect.height - side * board.size.y) / 2.0)

    self.pos = base

    redraw
  end
  
  def add_piece(p, piece, opts = {})
    opts = opts.merge :pos => to_real(p),
                      :name => piece.name
    add_item p, @theme.pieces.pixmap(piece, @unit), opts
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
  
  def mousePressEvent(e)
    if e.button == Qt::RightButton
      # go back using the right button
      self.selection = nil
      changed
      notify_observers :back => nil
    else
      p = to_logical(e.pos)
      
      if selection
        move = @game.move.new(selection, p, :promotion => :queen)
        validate = @game.validator.new(@state)
        if validate[move]
          perform! move
          notify_observers :new_move => { :move => move, :state => @state.dup }
        end
        
        self.selection = nil
      elsif @game.policy.movable?(@state, p)
        self.selection = p
      end
    end
  end
  
  def perform!(move)
    @state.perform!(move)
    animate :forward, move
  end
  
  def back(state, move)
    @state = state.dup
    animate :back, move
  end
  
  def forward(state, move)
    @state = state.dup
    animate :forward, move
  end
  
  def warp(state)
    @state = state.dup
    animate :warp, :instant => true
  end
  
  def animate(direction, *args)
    animation = @animator.send(direction, @state, *args)
    @field.run animation
    changed
  end
end
