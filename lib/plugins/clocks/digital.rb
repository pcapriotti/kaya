require 'plugins/plugin'
require 'constrained_text_item'
require 'board/item_bag'

class DigitalClock < Qt::GraphicsItemGroup
  include Plugin
  include ItemBag
  include ItemUtils
  include Observer
  
  plugin :name => 'Digital Clock',
         :keywords => %w(clock)

  attr_reader :items, :rect
  
  OFF_TEXT = '-'
  BASE_DIR = File.dirname(__FILE__)
  ACTIVE_SKIN_RENDERER = Qt::SvgRenderer.new(
      File.join(BASE_DIR, 'active_clock.svg'))
  INACTIVE_SKIN_RENDERER = Qt::SvgRenderer.new(
      File.join(BASE_DIR, 'inactive_clock.svg'))
          
  def initialize(scene)
    super(nil, @scene = scene)
    
    @items = {
      :time => ConstrainedTextItem.new(OFF_TEXT, self),
      :player => ConstrainedTextItem.new('', self),
      :caption => ConstrainedTextItem.new('', self)
    }
    
    @active = false
  end
  
  def set_geometry(rect)
    @rect = Qt::RectF.new(rect)
    self.pos = @rect.top_left
    redraw
  end
  
  def redraw
    if @rect
      add_item :skin, skin, :z => BACKGROUND_ZVALUE
      @items[:time].constraint = Qt::RectF.new(
        @rect.width * 0.4, @rect.height * 0.1, 
        @rect.width * 0.6, @rect.height * 0.62)
      @items[:caption].constraint = Qt::RectF.new(
        @rect.width * 0.02, @rect.height * 0.22,
        @rect.width * 0.4, @rect.height * 0.38)
      @items[:player].constraint = Qt::RectF.new(
        @rect.width * 0.14, @rect.height * 0.68,
        @rect.width * 0.69, @rect.height * 0.28)
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
  
  def skin
    renderer = if @active
      ACTIVE_SKIN_RENDERER
    else
      INACTIVE_SKIN_RENDERER
    end
    Qt::Image.from_renderer(@rect.size, renderer).to_pix
  end
  
  def start
    @clock.start
    self.active = true
  end
  
  def stop
    @clock.stop
    self.active = false
  end
  
  def active=(value)
    @active = value
    redraw
  end
  
  def active?
    @active
  end
  
  def data=(d)
    @caption = d[:color].to_s.capitalize
    @player = d[:player] || '(unknown)'
    
    items[:caption].text = @caption
    items[:player].text = @player
  end
end
