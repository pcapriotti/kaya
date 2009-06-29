# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'ics/connection'
require 'ics/example/window'

description = "Connection example"
version = "0.1"
about = KDE::AboutData.new("connection", 
                           "Connection Example", 
                           KDE.ki18n("Connection Example"),
                           version, 
                           KDE.ki18n(description),
                           KDE::AboutData::License_GPL,
                           KDE.ki18n("(C) 2009 Paolo Capriotti"))

KDE::CmdLineArgs.init(ARGV, about)

app = KDE::Application.new

w = Window.new
w.show

app.exec

