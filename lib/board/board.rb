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
  include ItemUtils

  attr_reader :scene, :items, :state, :unit, :rect, :theme
  attr_accessor :movable
  square_tag :selection
  square_tag :last_move_src, :highlight
  square_tag :last_move_dst, :highlight

  def initialize(scene, theme, game, state, field)
    super(nil, scene)
    @scene = scene
    @scene.add_element(self)
    @theme = theme
    @items = {}
    
    @game = game
    
    @state = state
    unless @state
      @state = @game.state.new
      @state.setup
    end
    
    @animator = @game.animator.new(self)
    
    @field = field
    @flipped = false
    @movable = lambda { true }
  end
  
  def flipped?
    @flipped
  end
  
  def flip!(value = nil)
    old = @flipped
    if value.nil?
      @flipped = !@flipped
    else
      @flipped = value
    end
    redraw if old != @flipped
  end
  
  def redraw
    board = @state.board
    @items.keys.each {|key| remove_item(key) }
    board.each_square do |p|
      piece = board[p]
      add_piece(p, piece) if piece
    end
    
    add_item :background, 
             @theme.board.pixmap(@unit), 
             :z => BACKGROUND_ZVALUE
  end
  
  def set_geometry(rect)
    @rect = rect
    board = @state.board
    side = [@rect.width / board.size.x, @rect.height / board.size.y].min.floor
    @unit = Qt::PointF.new(side, side)
    base = Qt::PointF.new(((@rect.width - side * board.size.x) / 2.0).to_i,
                          ((@rect.height - side * board.size.y) / 2.0).to_i)

    self.pos = base + @rect.top_left

    redraw
  end
  
  def add_piece(p, piece, opts = {})
    opts = opts.merge :pos => to_real(p),
                      :name => piece.name
    add_item p, @theme.pieces.pixmap(piece, @unit), opts
  end
  
  def on_click(pos)
    p = to_logical(pos)
    
    if selection
      move = @game.policy.new_move(@state, selection, p)
      validate = @game.validator.new(@state)
      if validate[move]
        perform! move
        fire :new_move => { :move => move, :state => @state.dup }
      end
      
      self.selection = nil
    elsif @game.policy.movable?(@state, p) and
          @movable[@state, p]
      self.selection = p
    end
  end
  
  def highlight(move)
    if move
      self.last_move_src = move.src
      self.last_move_dst = move.dst
    else
      self.last_move_src = nil
      self.last_move_dst = nil
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
