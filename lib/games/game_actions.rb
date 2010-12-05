# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
require 'action_provider'

module GameActions
  include ActionProvider
  
  def actions(parent, collection, policy)
    actions = (@action_data || []).map{|data| create_action(data, parent, collection, policy) }
    actions
  end
  
  def create_action(data, parent, collection, policy)
    icon = if data.opts[:icon]
      KDE::Icon.new(data.opts[:icon])
    else
      KDE::Icon.new
    end
    text = data.opts[:text] || data.id.to_s
    a = KDE::Action.new(icon, text, parent)
    collection[data.id] = a
    if data.opts.has_key?(:checked)
      a.checkable = true
      a.checked = data.opts[:checked]
      a.connect(SIGNAL('toggled(bool)')) do |value|
        data.action[value, policy]
      end
    else
      a.on(:triggered) { data.action[policy] }
    end
    a
  end
end
