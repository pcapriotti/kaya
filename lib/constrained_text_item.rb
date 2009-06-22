class ConstrainedTextItem < Qt::GraphicsItem
  attr_reader :text

  def initialize(text, parent, constraint = Qt::RectF.new, opts = {})
    super(parent)
    @text = text.to_s
    @parent = parent
    @constraint = constraint
    
    @font = opts[:font] || Qt::Font.new
    @color = opts[:color] || Qt::Color.new(Qt::black)
    
    update_metrics
  end
  
  def paint(p, opts, widget)
    p.pen = @color
    p.font = @font
    p.saving do
      p.translate(@constraint.center)
      p.scale(@factor, @factor)
      p.translate(-@brect.center)
      p.draw_text(0, 0, @text)
    end
  end
  
  def boundingRect
    @constraint
  end

  def text=(value)
    @text = value.to_s
    update_metrics
    update @constraint
  end
  
  def constraint=(value)
    @constraint = Qt::RectF.new(value)
    update_metrics
    update @constraint
  end
  
  def update_metrics
    @brect = Qt::FontMetrics.new(@font).bounding_rect(@text)
    @factor = [
      0.9 * @constraint.width / @brect.width,
      @constraint.height / @brect.height].min
  end
  
  alias :name :text  
end
