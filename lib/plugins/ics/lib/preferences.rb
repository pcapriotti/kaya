# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require_bundle 'ics', 'config'

module ICS

class Preferences < KDE::Dialog
  def initialize(parent)
    super(parent)
    @gui = KDE::autogui(:preferences, 
                        :caption => KDE::i18n("Configure ICS")) do |b|
      b.layout(:type => :vertical) do |vl|
        vl.layout(:type => :horizontal) do |l|
          l.label(:text => KDE::i18n("&Username:"),
                  :buddy => :username)
          l.line_edit(:username)
        end
        
        vl.layout(:type => :horizontal) do |l|
          l.label(:text => KDE::i18n("&Password:"),
                  :buddy => :password)
          l.line_edit(:password)
        end
      end
    end
    
    setGUI(@gui)
    
    data = Config.load
    username.text = data[:username]
    password.text = data[:password]
    
    on(:ok_clicked) do
      Config.save :username => username.text,
                  :password => password.text
    end
  end
end

end