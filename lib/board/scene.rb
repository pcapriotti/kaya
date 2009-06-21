class Scene < Qt::GraphicsScene
  def initialize
    super
    
    @elements = []
  end

  def add_element(element)
    @elements << element
  end
  
  def mousePressEvent(e)
    if e.button == Qt::LeftButton
      @elements.each do |element|
        if element.rect.contains(e.scene_pos)
          element.on_click(e.scene_pos - element.rect.top_left)
        end
      end
    end
  end
end
