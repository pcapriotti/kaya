require 'board/board'
require 'games/chess/state'
require 'games/chess/board'
require 'point'

class Table < Qt::GraphicsView
  def initialize(scene, *elements)
    super(@scene = scene)
    @elements = elements
  end
  
  def resizeEvent(e)
    r = Qt::RectF.new(0, 0, e.size.width, e.size.height)
    @scene.scene_rect = r
    @elements.each {|e| e.on_resize(r) }
  end
end
