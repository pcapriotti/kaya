require 'item'

class Pool < Qt::GraphicsItemGroup
  BACKGROUND_ZVALUE = -10
  
  include Observable
  include ItemUtils
  include ItemBag
  
  attr_reader :rect, :scene, :items
  
  def initialize(scene, theme, game)
    super(nil, scene)
    @scene = scene
    @scene.add_element(self)
    
    @theme = theme
    @game = game
    
    @items = []
    @size = Point.new(3, 5)
    
    @type_values = Hash.new(-1)
    if @game.respond_to? :types
      @game.types.each_with_index do |type, index|
        @type_values[type] = index
      end
    end
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
    
    side = (@rect.width / @size.x).floor
    @unit = Qt::Point.new(side, side)
    redraw
  end
  
  def add_piece(index, piece, opts = {})
    opts = opts.merge :pos => to_real(index),
                      :name => piece
    item = create_item index, @theme.pieces.pixmap(piece, @unit), opts
    items.insert(index, item)
    
    # TODO shift the other items
    
    item
  end
  
  def warp(pool)
    pieces = pool.pieces.
      map{|piece, count| [piece] * count}.
      inject([]){|a, b| a.concat(b)}.
      sort {|p1, p2| compare(p1, p2) }
    (0...[pieces.size, @items.size].min).each do |i|
      if pieces[i] != @items[i].name
        destroy_item @items[i]
        @items[i] = create_item i, @theme.pieces.pixmap(pieces[i], @unit),
            :pos => to_real(i), :name => pieces[i]
      end
    end
    
    if pieces.size > @items.size
      (@items.size...pieces.size).each do |i|
        add_piece(i, pieces[i])
      end
    elsif pieces.size < @items.size
      @items[pieces.size..-1].each {|item| destroy_item(item) }
      puts "items = #{@items.inspect}"
      puts "items2 = #{@items[0...pieces.size].inspect}"
      @items = @items[0...pieces.size]
    end
  end
  
  def on_click(pos)
    index = to_logical(pos)
  end
  
  def to_logical(p)
    result = Point.new((p.x.to_f / @unit.x).floor,
                       (p.y.to_f / @unit.y).floor)
    y = result.y
    x = y % 2 == 0 ? result.x : @size.x - result.x - 1
    x + y * @size.x
  end
  
  def to_real(index)
    x = index % @size.x
    y = index / @size.x
    x = @size.x - x - 1 if y % 2 == 1
    
    Qt::PointF.new(x * @unit.x, y * @unit.y)
  end
  
  def compare(piece1, piece2)
    [piece1.color.to_s, @type_values[piece1.type], piece1.type.to_s] <=>
    [piece2.color.to_s, @type_values[piece2.type], piece2.type.to_s]
  end
end
