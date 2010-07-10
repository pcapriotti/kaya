require 'toolkit'
require 'require_bundle'
require 'plugins/loader'
require 'clock'
require 'observer_utils'
$loader = PluginLoader.new

app = KDE::Application.init(:id => "timers")

class View < Qt::GraphicsView
  include Observable
  
  def initialize(parent)
    super(parent)
  end
  
  def resizeEvent(e)
    fire :resize => e.size
  end
end

main = Qt::Widget.new
gui = KDE::autogui("main") do |g|
  g.layout(:vertical) do |l|
    l.widget(:factory => View,
             :name => :view)
  end
end
main.setGUI(gui)

scene = Qt::GraphicsScene.new
main.view.scene = scene

display = $loader.get_matching(:clock)
clock = display.new(scene, lambda{|x| x})
main.view.on(:resize) do |size|
  clock.set_geometry(Qt::Rect.new(0, 0, size.width, size.height))
end
clock.show

clock.clock = Clock.new(72, 0)
clock.start



main.show
app.exec