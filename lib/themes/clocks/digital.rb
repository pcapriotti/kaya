require 'themes/theme'
require 'constrained_text_item'

class DigitalClock < Qt::GraphicsItemGroup
  include Theme
  include ItemBag
  include ItemUtils
  include Observer
  
  theme :name => 'Digital Clock',
        :keywords => %w(clock)

  attr_reader :items, :rect, :clock
  
  OFF_TEXT = '-'
          
  class RoundedRectItem < Qt::AbstractGraphicsShapeItem
    def initialize(parent, rect = Qt::RectF.new)
      super(parent)
      @rect = rect
    end
    
    def paint(p, opts, widget)
      p.render_hint = Qt::Painter::Antialiasing
      p.draw_rounded_rect(@rect, 5, 5)
    end

    def boundingRect
      @rect
    end

    def set_rect(x, y, width, height)
      @rect = Qt::RectF.new(x, y, width, height)
      update
    end
    
    def rect=(value)
      set_rect(value.x, value.y, value.width, value.height)
    end
  end
          
  def initialize(scene)
    super(nil, @scene = scene)
    
    @items = {
      :border => RoundedRectItem.new(self),
      :time => ConstrainedTextItem.new(OFF_TEXT, self)
    }
    
    @items[:border].z_value = 10
  end
  
  def set_geometry(rect)
    @rect = rect
    redraw
  end
  
  def redraw
    if @rect
      @items[:border].rect = @rect
      @items[:time].constraint = @rect
    end
  end
  
  def clock=(clock)
    if @clock
      @clock.delete_observer(self)
    end
    
    @clock = clock
    clock.add_observer(self)
    on_timer(clock.timer)
  end
  
  def on_timer(data)
    min = data[:main] / 60
    sec = data[:main] % 60
    
    @items[:time].text = "%02d:%02d" % [min, sec]
  end
end
