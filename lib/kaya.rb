# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

#!/usr/bin/env ruby
$:.unshift(File.dirname(__FILE__))
require 'qtutils'
require 'mainwindow'

def version
  "0.3"
end

def start_kaya
  default_game = :chess

  app = KDE::Application.init(
    :version => version,
    :id => 'kaya',
    :name => KDE.ki18n('Kaya'),
    :description => KDE.ki18n('KDE Board Game Suite'),
    :copyright => KDE.ki18n('(C) 2009 Paolo Capriotti'),
    :authors => [[KDE.ki18n('Paolo Capriotti'), 'p.capriotti@gmail.com']],
    :contributors => [[KDE.ki18n("Jani Huhtanen"), KDE.ki18n('Gaussian blur code')],
                      [KDE.ki18n("Yann Dirson"), KDE.ki18n('Minishogi')]],
    :bug_tracker => 'http://github.com/pcapriotti/kaya/issues',
    :options => [['+[game]', KDE.ki18n('Initial game')]])
    
  require 'plugins/loader'
  require 'games/all'
  require 'ext/loader'
    
  args = KDE::CmdLineArgs.parsed_args
  game = if args.count > 0
    name = args.arg(0)
    g = Game.get(name.to_sym)
    unless g
      warn "No such game #{name}. Defaulting to #{default_game}"
      nil
    else
      g
    end
  end
  game ||= Game.get(default_game)

  plugin_loader = PluginLoader.new
  
  main = MainWindow.new(plugin_loader, game)
  
  
  
  main.show
  app.exec
end
