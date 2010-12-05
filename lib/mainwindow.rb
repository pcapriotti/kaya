# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'
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
require 'theme_prefs'
require 'view'
require 'multiview'

require 'kaya_ui'

class MainWindow < KDE::XmlGuiWindow
  include ActionHandler
  include FileWriter
  
  attr_reader :console
  attr_reader :view

  def initialize(loader, game)
    super nil
    
    @loader = loader
    @theme_loader = @loader.get_matching(:theme_loader).new
    
    @factories = Hash.new do |h, interface|
      @loader.get_matching(interface)
    end
    @factories[:table] = Factory.new do |parent|
        Table.new(Scene.new, @loader, @theme_loader, parent)
      end
    @factories[:controller] = Factory.new do |parent|
      Controller.new(parent, @field).tap do |c|
        c.on(:changed_active_actions) do
          update_active_actions(c)
        end
        c.on(:reset) do
          update_game_actions(c)
        end
      end
    end

    startup(game)
    setup_actions
    load_action_providers
    setGUI(Kaya::GUI)
    new_game(Match.new(game), :new_tab => false)
  end
  
  def closeEvent(event)
    saveGUI
    if controller.match
      controller.match.close
    end
    event.accept
  end

  def controller
    @view.current.controller
  end

private

  def setup_actions
    @actions = { }
    regular_action(:open_new,
                   :icon => 'document-new',
                   :text => KDE::i18n("&New..."),
                   :shortcut => KDE::std_shortcut(:new),
                   :tooltip => KDE::i18n("Start a new game...")) do
      create_game
    end
    
    regular_action(:open,
                   :icon => 'document-open',
                   :text => KDE::i18n("&Load..."),
                   :shortcut => KDE::std_shortcut(:open),
                   :tooltip => KDE::i18n("Open a saved game...")) do
      load_game
    end
    
    regular_action(:quit,
                   :icon => 'application-exit',
                   :text => KDE::i18n("&Quit"),
                   :shortcut => KDE::std_shortcut(:quit),
                   :tooltip => KDE::i18n("Quit the program")) do
      close
    end
    
    regular_action(:save,
                   :icon => 'document-save',
                   :text => KDE::i18n("&Save"),
                   :shortcut => KDE::std_shortcut(:save),
                   :tooltip => KDE::i18n("Save the current game")) do
      save_game
    end
    
    regular_action(:save_as,
                   :icon => 'document-save-as',
                   :text => KDE::i18n("Save &As..."),
                   :tooltip => KDE::i18n("Save the current game to another file")) do
      save_game_as
    end
    
    @actions[:back] = regular_action :back, :icon => 'go-previous', 
                          :text => KDE.i18n("B&ack") do
      controller.back
    end
    @actions[:forward] = regular_action :forward, :icon => 'go-next', 
                             :text => KDE.i18n("&Forward") do
      controller.forward
    end
    
    regular_action :flip, :icon => 'object-rotate-left',
                          :text => KDE.i18n("F&lip") do
      table = @view.current.table
      table.flip(!table.flipped?)
    end
    
    regular_action :configure_engines,
                   :icon => 'help-hint',
                   :text => KDE.i18n("Configure &Engines...") do
      dialog = EnginePrefs.new(@engine_loader, self)
      dialog.show
    end
    
    regular_action :configure_themes,
                   :icon => 'games-config-theme',
                   :text => KDE.i18n("Configure &Themes...") do
      dialog = ThemePrefs.new(@loader, @theme_loader, self)
      dialog.on(:ok) { controller.reset }
      dialog.show
    end
    
    @actions[:undo] = regular_action(:undo,
            :icon => 'edit-undo',
            :text => KDE::i18n("Und&o"),
            :shortcut => KDE::std_shortcut(:undo),
            :tooltip => KDE::i18n("Undo the last history operation")) do
      controller.undo!
    end

    @actions[:redo] = regular_action(:redo,
            :icon => 'edit-redo',
            :text => KDE::i18n("Re&do"),
            :shortcut => KDE::std_shortcut(:redo),
            :tooltip => KDE::i18n("Redo the last history operation")) do
      controller.redo!
    end
  end
  
  def load_action_providers
    @loader.get_all_matching(:action_provider).each do |provider_klass|
      provider = provider_klass.new
      ActionProviderClient.new(self, provider)
    end
  end
  
  def startup(game)
    @field = AnimationField.new(20)

    movelist_stack = Qt::StackedWidget.new(self)
    movelist_dock = Qt::DockWidget.new(self)
    movelist_dock.widget = movelist_stack
    movelist_dock.window_title = KDE.i18n("History")
    movelist_dock.object_name = "movelist"
    add_dock_widget(Qt::LeftDockWidgetArea, movelist_dock, Qt::Vertical)
    movelist_dock.show
    action_collection[:toggle_history] = movelist_dock.toggle_view_action

    @view = MultiView.new(self, movelist_stack, @factories)
    @view.create(:name => game.class.plugin_name)
    @view.on(:changed) do
      update_active_actions(controller)
      update_title
      update_game_actions(controller)
    end
    @view.clean = true

    update_title
    
    @engine_loader = @loader.get_matching(:engine_loader).new
    @engine_loader.reload
    
    @console = Console.new(nil)
    console_dock = Qt::DockWidget.new(self)                                                      
    console_dock.widget = @console                                                             
    console_dock.focus_proxy = @console                                                        
    console_dock.window_title = KDE.i18n("Console")                                              
    console_dock.object_name = "console"                                                         
    add_dock_widget(Qt::BottomDockWidgetArea, console_dock, Qt::Horizontal)                      
    console_dock.window_flags = console_dock.window_flags & ~Qt::WindowStaysOnTopHint            
    console_dock.show
    action_collection[:toggle_console] = console_dock.toggle_view_action
    
    self.central_widget = @view
  end
  
  def new_game(match, opts = { })
    setup_single_player(match)
    controller.reset(match)
  end
  
  def setup_single_player(match)
    controller.color = match.game.players.first
    controller.premove = false
    opponents = match.game.players[1..-1].map do |color|
      DummyPlayer.new(color)
    end
    opponents.each do |p| 
      controller.add_controlled_player(p)
    end

    controller.controlled.values.each do |p|
      match.register(p)
    end
    controller.controlled.values.each do |p|
      match.start(p)
    end
  end

  def create_game(opts = { })
    current_game = if controller.match 
      controller.match.game
    end
    diag = NewGame.new(self, @engine_loader, current_game)
    diag.on(:ok) do |data|
      game = data[:game]
      match = Match.new(game, :editable => data[:engines].empty?)
      if data[:new_tab]
        @view.create(:activate => true,
                     :force => true,
                     :name => game.class.plugin_name)
      else
        @view.set_tab_text(@view.index, game.class.plugin_name)
        update_title
      end
      contr = controller
      
      
      match.on(:started) do
        contr.reset(match)
      end
      
      # set up engine players
      players = game.players
      data[:engines].each do |player, engine|
        e = engine.new(player, match)
        e.start
      end
      
      # set up human players
      if data[:humans].empty?
        contr.color = nil
      else
        contr.color = data[:humans].first
        contr.premove = data[:humans].size == 1
        match.register(contr)
        
        data[:humans][1..-1].each do |player|
          p = DummyPlayer.new(player)
          contr.add_controlled_player(p)
          match.register(p)
        end
      end
      contr.controlled.values.each {|p| match.start(p) }
    end
    diag.show
  end

  def load_game
    url = KDE::FileDialog.get_open_url(KDE::Url.new, '*.*', self,
      KDE.i18n("Open game"))
    
    return if url.is_empty or (not url.path)
    
    puts "url = #{url.inspect}"
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
    
    tmp_file = KDE::download_tempfile(url, self)
    return unless tmp_file

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
    @view.create(:activate => true,
                  :name => game.class.plugin_name)
    setup_single_player(match)
    match.history = history
    match.add_info(info)
    match.url = url
    controller.reset(match)
  end
  
  def save_game_as
    match = controller.match
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
    match = controller.match
    if match
      if match.url
        write_game
      else
        save_game_as
      end
    end
  end
  
  def write_game(url = nil)
    return if url.is_empty or (not url.path)
    
    match = controller.match
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
  
  def update_game_actions(contr)
    unplug_action_list(:game_actions)
    if contr.match
      game = contr.match.game
      actions = if game.respond_to?(:actions)
        game.actions(self, action_collection, contr.policy)
      else
        []
      end
      plug_action_list(:game_actions, actions)
    end
  end
  
  def update_title
    self.caption = @view.current_name
  end
  
  def update_active_actions(contr)
    if contr == controller
      contr.active_actions.each do |id, enabled|
	action = @actions[id]
	if action
	  action.enabled = enabled
	end
      end
    end
  end
end
