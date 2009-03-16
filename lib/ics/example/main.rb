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

