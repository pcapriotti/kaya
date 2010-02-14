# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require_bundle 'ics', 'config'

module ICS

class Preferences < KDE::Dialog
  def initialize(parent)
    super(parent)
    
    widget = Qt::Widget.new(self)
    layout = Qt::VBoxLayout.new(widget)
    
    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE::i18n("&Username:"), widget)
    tmp.add_widget(label)
    username = Qt::LineEdit.new(widget)
    tmp.add_widget(username)
    label.buddy = username
    layout.add_layout(tmp)
    
    tmp = Qt::HBoxLayout.new
    label = Qt::Label.new(KDE::i18n("&Password:"), widget)
    tmp.add_widget(label)
    password = Qt::LineEdit.new(widget)
    password.echo_mode = Qt::LineEdit::Password
    label.buddy = password
    tmp.add_widget(password)
    layout.add_layout(tmp)
    
    self.main_widget = widget
    self.caption = KDE::i18n("Configure ICS")

    data = Config.load
    username.text = data[:username]
    password.text = data[:password]
    
    on(:okClicked) do
      Config.save :username => username.text,
                  :password => password.text
    end
  end
end

end