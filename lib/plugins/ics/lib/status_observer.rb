# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class StatusObserver
  MESSAGES = {
    :disconnected => { :permanent => '', :temporary => KDE.i18n("Disconnected from ICS Server") },
    :established => { :temporary => KDE.i18n("Connection established") },
    :connecting => { :permanent => KDE.i18n("Connecting...") },
    :logging_in => { :permanent => KDE.i18n("Logging in...") },
    :logged_in => { :temporary => KDE.i18n("Logged in"), :permanent => KDE.i18n("Connected to ICS server") }
  }

  def initialize(set_temporary, set_permanent)
    @set_temporary = set_temporary
    @set_permanent = set_permanent
    switch_to(:disconnected)
  end

  def link_to(connection, protocol)
    connection.on(:connecting) { switch_to :connecting }
    connection.on(:established) { switch_to :established }
    connection.on(:closed) { switch_to :disconnected }
    protocol.on(:login_prompt) { switch_to :logging_in }
    protocol.observe_limited(:prompt) do
      switch_to(:logged_in)
      true
    end
  end

  def switch_to(state)
    @state = state
    messages = MESSAGES[state]
    if messages
      @set_permanent[messages[:permanent]] if messages[:permanent]
      @set_temporary[messages[:temporary]] if messages[:temporary]
    end
  end
end
