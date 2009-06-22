class ConstrainedTextItem < Qt::GraphicsItem
  def initialize(text, parent, constraint, opts = {})
    super(parent)
    @text = text
    @parent = parent
    @constraint = constraint
    
    @font = opts[:font] || Qt::Font.new
    @color = opts[:color] || Qt::Color.new(Qt::black)
    
    @brect = Qt::FontMetrics.new(@font).bounding_rect(@text)
    @factor = [
      0.9 * @constraint.width / @brect.width,
      @constraint.height / @brect.height].min
  end
  
  def paint(p, opts, widget)
    p.pen = @color
    p.font = @font
    p.draw_rect @constraint
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
  
  def name
    @text
  end
end