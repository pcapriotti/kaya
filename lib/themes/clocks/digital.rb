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
          
  def initialize(scene)
    super(nil, @scene = scene)
    
    @items = {
      :border => Qt::GraphicsRectItem.new(self),
      :time => ConstrainedTextItem.new(OFF_TEXT, self)
    }
  end
  
  def set_geometry(rect)
    @rect = rect
    redraw
  end
  
  def redraw
    @items[:border].set_rect(@rect.x, @rect.y, @rect.width, @rect.height)
    @items[:time].constraint = @rect
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
