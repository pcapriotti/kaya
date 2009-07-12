# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'
require 'board/board'
require 'board/pool'
require 'board/table'
require 'board/scene'
require 'interaction/history'
require 'controller'
require 'dummy_player'

require 'interaction/match'

require 'console'

require 'filewriter'
require 'newgame'
require 'engine_prefs'

class MainWindow < KDE::XmlGuiWindow
  include ActionHandler
  include FileWriter
  
  attr_reader :console
  attr_reader :controller

  def initialize(loader, game)
    super nil
    
    @loader = loader
    @default_game = game
    
    startup
    setup_actions
    load_action_providers
    setupGUI
    new_game(Match.new(game))
  end
  
  def closeEvent(event)
    if @controller.match
      @controller.match.close
    end
    event.accept
  end

private

  def setup_actions
    @actions = { }
    std_action(:open_new) { create_game }
    std_action(:open) { load_game }
    std_action :quit, :slot => :close
    std_action(:save) { save_game }
    std_action(:saveAs) { save_game_as }
    
    @actions[:back] = regular_action :back, :icon => 'go-previous', 
                          :text => KDE.i18n("B&ack") do
      @controller.back
    end
    @actions[:forward] = regular_action :forward, :icon => 'go-next', 
                             :text => KDE.i18n("&Forward") do
      @controller.forward
    end
    
    regular_action :flip, :icon => 'object-rotate-left',
                          :text => KDE.i18n("F&lip") do
      @table.flip(! @table.flipped?)
    end
    
    regular_action :configure_engines,
                   :icon => 'help-hint',
                   :text => KDE.i18n("Configure &Engines...") do
      dialog = EnginePrefs.new(@engine_loader, self)
      dialog.show
    end
    
    @actions[:undo] = std_action(:undo) do
      @controller.undo!
    end

    @actions[:redo] = std_action(:redo) do
      @controller.redo!
    end
  end
  
  def load_action_providers
    @loader.get_all_matching(:action_provider).each do |provider_klass|
      provider = provider_klass.new
      ActionProviderClient.new(self, provider)
    end
  end
  
  def startup
    scene = Scene.new
    @table = Table.new scene, @loader, self
    field = AnimationField.new(20)
    @controller = Controller.new(@table, field)
    @controller.observe(:active_actions) do |actions|
      actions.each do |id, enabled|
        a = @actions[id]
        a.enabled = enabled if a
      end
    end
    @table.observe(:reset) do |match|
      update_game_actions(match)
    end
    @engine_loader = @loader.get_matching(:engine_loader).new
    @engine_loader.reload

    movelist = @loader.get_matching(:movelist).new(@controller)
    movelist_dock = Qt::DockWidget.new(self)
    movelist_dock.widget = movelist
    movelist_dock.window_title = KDE.i18n("History")
    movelist_dock.object_name = "movelist"
    add_dock_widget(Qt::LeftDockWidgetArea, movelist_dock, Qt::Vertical)
    movelist_dock.show

    @console = Console.new(nil)
    console_dock = Qt::DockWidget.new(self)                                                      
    console_dock.widget = @console                                                             
    console_dock.focus_proxy = @console                                                        
    console_dock.window_title = KDE.i18n("Console")                                              
    console_dock.object_name = "console"                                                         
    add_dock_widget(Qt::BottomDockWidgetArea, console_dock, Qt::Horizontal)                      
    console_dock.window_flags = console_dock.window_flags & ~Qt::WindowStaysOnTopHint            
    console_dock.show
    
    self.central_widget = @table
  end
  
  def new_game(match)
    setup_single_player(match)
    @controller.reset(match)
  end
  
  def setup_single_player(match)
    @controller.color = match.game.players.first
    @controller.premove = false
    opponents = match.game.players[1..-1].map do |color|
      DummyPlayer.new(color)
    end
    opponents.each do |p| 
      @controller.add_controlled_player(p)
    end

    @controller.controlled.values.each do |p|
      match.register(p)
    end
    @controller.controlled.values.each do |p|
      match.start(p)
    end
  end

  def create_game
    current_game = if @controller.match 
      @controller.match.game
    end
    diag = NewGame.new(self, @engine_loader, current_game)
    diag.observe(:ok) do |data|
      game = data[:game]
      match = Match.new(game, :editable => data[:engines].empty?)
      
      match.observe(:started) { @controller.reset(match) }
      
      # set up engine players
      players = game.players
      data[:engines].each do |player, engine|
        e = engine.new(player, match)
        e.start
      end
      
      # set up human players
      if data[:humans].empty?
        @controller.color = nil
      else
        @controller.color = data[:humans].first
        @controller.premove = data[:humans].size == 1
        match.register(@controller)
        
        data[:humans][1..-1].each do |player|
          p = DummyPlayer.new(player)
          @controller.add_controlled_player(p)
          match.register(p)
        end
      end
      @controller.controlled.values.each {|p| match.start(p) }
    end
    diag.show
  end

  def load_game
    url = KDE::FileDialog.get_open_url(KDE::Url.new, '*.*', self,
      KDE.i18n("Open game"))
    unless url.is_empty
      # find readers
      ext = File.extname(url.path)[1..-1]
      return unless ext
      readers = Game.to_enum.find_all do |_, game|
        game.respond_to?(:game_extensions) and
        game.game_extensions.include?(ext)
      end.map do |_, game|
        [game, game.game_reader]
      end
      
      if readers.empty?
        warn "Unknown file extension #{ext}"
        return
      end
      
      tmp_file = ""
      return unless KIO::NetAccess.download(url, tmp_file, self)

      history = nil
      game = nil
      info = nil
      
      readers.each do |g, reader|
        begin
          data = File.open(tmp_file) do |f|
            f.read
          end
          i = {}
          history = reader.read(data, i)
          game = g
          info = i
          break
        rescue ParseException
        end
      end
      
      unless history
        warn "Could not load file #{url.path}"
        return
      end
      
      # create game
      match = Match.new(game)
      setup_single_player(match)
      match.history = history
      match.add_info(info)
      match.url = url
      @controller.reset(match)
    end
  end
  
  def save_game_as
    match = @controller.match
    if match
      pattern = if match.game.respond_to?(:game_extensions)
        match.game.game_extensions.map{|ext| "*.#{ext}"}.join(' ')
      else
        '*.*'
      end
      url = KDE::FileDialog.get_save_url(
        KDE::Url.new, pattern, self, KDE.i18n("Save game"))
      match.url = write_game(url)
    end
  end
  
  def save_game
    match = @controller.match
    if match
      if match.url
        write_game
      else
        save_game_as
      end
    end
  end
  
  def write_game(url = nil)
    match = @controller.match
    if match
      url ||= match.url
      writer = match.game.game_writer
      info = match.info
      info[:players] = info[:players].inject({}) do |res, pl|
        res[pl.color] = pl.name
        res
      end
      result = writer.write(info, match.history)
      write_file(url, result)
    end
  end
  
  def update_game_actions(match)
    unplug_action_list('game_actions')
    actions = if match.game.respond_to?(:actions)
      match.game.actions(self, action_collection, @controller.policy)
    else
      []
    end
    plug_action_list('game_actions', actions)
  end
end
