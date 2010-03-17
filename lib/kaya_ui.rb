# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'

module Kaya
  GUI = KDE::gui(:kaya) do |g|
    g.menu_bar do |mb|
      mb.menu(:file) do |m|
        m.group(:file_extensions)
      end
      
      mb.menu(:edit) do |m|
        m.action :undo
        m.action :redo
      end
      
      mb.menu(:gameMenu, KDE::i18n("&Game")) do |m|
        m.action :begin
        m.action :back
        m.action :pause
        m.action :forward
        m.action :end
        m.separator
        m.group :game_extensions
        m.separator
        m.action_list :game_actions
      end
      
      mb.menu(:viewMenu, KDE::i18n("&View")) do |m|
        m.action :flip
        m.action :toggle_console
        m.action :toggle_history
      end
      
      mb.menu(:settings) do |m|
        m.action :preferences
        m.action :configure_engines
        m.action :configure_themes
      end
    end
    
    g.tool_bar(:mainToolBar) do |tb|
      tb.action(:connect)
      tb.action(:disconnect)
    end
    
    g.tool_bar(:gameToolbar, KDE::i18n("Game Toolbar")) do |tb|
      tb.action :begin
      tb.action :back
      tb.action :pause
      tb.action :forward
      tb.action :end
      tb.action_list :variantActions
    end
  end
end
