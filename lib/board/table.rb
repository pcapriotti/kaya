class Table < Qt::GraphicsView
  def initialize(scene, theme, parent, elements)
    super(@scene = scene, parent)
    @theme = theme
    @elements = elements
  end
  
  def resizeEvent(e)
    r = Qt::RectF.new(0, 0, e.size.width, e.size.height)
    @scene.scene_rect = r
    @theme.layout.layout(r, @elements)
  end
end
