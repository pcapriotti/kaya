class Window < Qt::Widget
  def initialize(parent = nil)
    super parent

    quit = Qt::PushButton.new("Quit", self)
    connect(quit, SIGNAL(:clicked),
            self, SLOT(:close))

    start_button = Qt::PushButton.new("Start", self)
    start_button.on(:clicked) { start }

    layout = Qt::VBoxLayout.new
    layout.add_widget start_button
    layout.add_widget quit
    set_layout layout
    
    @conn = ICS::Connection.new('freechess.org', 5000)
    r = lambda do |text, off|
      puts "received (#{off}): #{text}"
    end
    @conn.on_received_line(&r)
    @conn.on_received_text(&r)
  end
  
  def start
    @conn.start
  end
end
