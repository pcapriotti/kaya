# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

class Console < Qt::Widget
  include Observable

  def initialize(parent)
    super(parent)
    
    layout = Qt::VBoxLayout.new
    @output = Qt::TextEdit.new(self)
    @input = Qt::LineEdit.new(self)
    
    layout.add_widget(@output)
    layout.add_widget(@input)
    setLayout layout
    
    @output.read_only = true
    f = @output.font
    f.family = 'monospace'
    f.point_size = 8
    @output.font = f
    @output.current_font = f
    @bold_font = f
    @bold_font.bold = true

    @input.on(:return_pressed) do
      text = @input.text
      with_font(@bold_font) do
        @output.append text
      end
      @input.text = ''
      fire :input => text
    end
  end

  def with_font(font)
    old = @output.current_font
    @output.current_font = font
    yield
    @output.current_font = old
  end
  
  def append(text)
    @output.append(text)
  end
end
