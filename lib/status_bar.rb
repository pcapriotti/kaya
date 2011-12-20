# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

class StatusBar < KDE::StatusBar
  def initialize(parent)
    super(parent)

    @label = Qt::Label.new(self)

    add_widget(@label)
  end

  def show_permanent_message(msg)
    @label.text = msg
  end
end
