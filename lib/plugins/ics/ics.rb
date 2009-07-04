# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'plugins/plugin'
require 'require_bundle'
require 'action_provider'
require_bundle 'ics', 'protocol'
require_bundle 'ics', 'connection'
require_bundle 'ics', 'match_handler'

class ICSPlugin
  include Plugin
  include ActionProvider
  
  plugin :name => 'ICS Plugin',
         :interface => :action_provider,
         :bundle => 'ics'
         
  def initialize
    action(:connect,
           :text => KDE.i18n("&Connect to ICS"),
           :icon => 'network-connect') do |parent|
      connect_to_ics(parent)
    end
    action(:disconnect,
           :text => KDE.i18n("&Disconnect from ICS"),
           :icon => 'network-disconnect') do |parent|
      if @connection
        @connection.close
        @connection = nil
      end
    end
  end
  
  def connect_to_ics(parent)
    protocol = ICS::Protocol.new(:debug)
    @connection = ICS::Connection.new('freechess.org', 23)
    config = KDE::Global.config.group("ICS")
    protocol.add_observer ICS::AuthModule.new(@connection, 
      config.read_entry('username', 'guest'), 
      config.read_entry('password', ''))
    protocol.add_observer ICS::StartupModule.new(@connection)
    protocol.link_to @connection

    protocol.observe :text do |text|
      parent.console.append(text)
    end

    parent.console.observe :input do |text|
      @connection.send_text text
    end

    @handler = ICS::MatchHandler.new(parent.controller, 
                                    protocol)

    @connection.start
  end
end
