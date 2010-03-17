# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'constrained_text_item'

module ClockDisplay
  OFF_TEXT = '-'
  
  def set_geometry(rect)
    @rect = Qt::RectF.new(rect)
    self.pos = @rect.top_left
    redraw
  end
  
  def create_display_items
    {
      :time => ConstrainedTextItem.new(OFF_TEXT, self),
      :player => ConstrainedTextItem.new('', self),
      :caption => ConstrainedTextItem.new('', self)
    }
  end
  
  def start
    @clock.start if @clock
    self.active = true
  end
  
  def stop
    @clock.stop if @clock
    self.active = false
  end
  
  def active=(value)
    @active = value
    redraw
  end
  
  def active?
    @active
  end
  
  def data=(d)
    @caption = translate[d[:color]]
    @player = d[:player] || KDE::i18n('(unknown)')
    
    items[:caption].text = @caption
    items[:player].text = @player
  end
  
  def clock=(clock)
    if @clock
      @clock.delete_observer(self)
    end
    
    @clock = clock
    clock.add_observer(self)
    on_timer(clock.timer)
  end
  
  def on_timer(data)
    min = data[:main] / 60
    sec = data[:main] % 60
    
    @items[:time].text = "%02d:%02d" % [min, sec]
  end
end
