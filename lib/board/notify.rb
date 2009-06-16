class Notify
  def initialize(window)
    @window = window
  end
  
  def [](events)
    events.each do |event, text|
      KDE::Notification.event(event.to_s, text,
        Qt::Pixmap.new, @window)
    end
  end
end