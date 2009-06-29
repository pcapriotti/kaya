# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

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
    @conn.on(:received_line, &r)
    @conn.on(:received_text, &r)
  end
  
  def start
    @conn.start
  end
end
