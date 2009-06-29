# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

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