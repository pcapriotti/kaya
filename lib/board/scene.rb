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
      pos = e.scene_pos.to_i
      @elements.each do |element|
        if element.rect.contains(pos)
          element.on_click(pos - element.rect.top_left)
        end
      end
    end
  end
end
