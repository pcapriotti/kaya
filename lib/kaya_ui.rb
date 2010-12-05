# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

module Kaya
  GUI = KDE::gui(:kaya) do |g|
    g.menu_bar do |mb|
      mb.menu(:game, :text => KDE::i18n("&Game")) do |m|
        m.action :open_new
        m.separator
        m.action :open
        m.action :save
        m.action :save_as
        m.separator
        m.group :file_extensions
        m.separator
        m.action :quit
      end
      
      mb.menu(:edit, :text => KDE::i18n("&Edit")) do |m|
        m.action :undo
        m.action :redo
      end
      
      mb.menu(:move, :text => KDE::i18n("&Move")) do |m|
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
      
      mb.menu(:viewMenu, :text => KDE::i18n("&View")) do |m|
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
    
    g.tool_bar(:main_toolbar, :text => KDE::i18n("&Main toolbar")) do |tb|
      tb.action :open_new
      tb.action :open
      tb.action :save
    end
    
    g.tool_bar(:edit_toolbar, :text => KDE::i18n("&Edit toolbar")) do |tb|
      tb.action :undo
      tb.action :redo
    end
    
    g.tool_bar(:move_toolbar, :text => KDE::i18n("Mo&ve Toolbar")) do |tb|
      tb.action :begin
      tb.action :back
      tb.action :pause
      tb.action :forward
      tb.action :end
    end
  end
end
