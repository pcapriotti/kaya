# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

Action = Struct.new(:id, :opts, :action)

module ActionProvider
  def action(id, opts = {}, &action)
    @action_data ||= []
    @action_data << Action.new(id, opts, action)
  end
  
  def each_action(&blk)
    @action_data.each(&blk)
  end
end

class ActionProviderClient < KDE::XMLGUIClient
  include ActionHandler
  
  def initialize(parent, provider)
    super(parent)
    @parent = parent

    KDE::with_xml_gui(provider.gui) do |file|
      setXMLFile(file)
    end
    provider.each_action do |action|
      regular_action(action.id, action.opts) do
        action.action[@parent]
      end
    end
  end
  
  def action_parent
    @parent
  end
end

