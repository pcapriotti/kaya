require 'qtutils'
require 'board/board'
require 'board/pool'
require 'board/table'
require 'board/scene'
require 'history'
require 'controller'

require 'interaction/match'

require 'ics/protocol'
require 'ics/match_handler'
require 'ics/connection'
require 'console'

require 'filewriter'
require 'newgame'

class MainWindow < KDE::XmlGuiWindow
  include ActionHandler
  include FileWriter

  def initialize(loader, game)
    super nil
    
    @loader = loader
    @default_game = game
    
    startup
    setup_actions
    setupGUI
    new_game(Match.new(game))
  end

private

  def setup_actions
    std_action(:open_new) do
      action = lambda do |game|
        new_game(Match.new(game))
      end
      diag = NewGame.new(self, action)
      diag.show
    end
    std_action(:open) { load_game }
    std_action :quit, :slot => :close
    std_action(:save) { save_game }
    std_action(:saveAs) { save_game_as }
    
    regular_action :back, :icon => 'go-previous', 
                          :text => KDE.i18n("B&ack") do
      @controller.back
    end
    regular_action :forward, :icon => 'go-next', 
                             :text => KDE.i18n("&Forward") do
      @controller.forward
    end
    regular_action :connect, :icon => 'network-connect',
                             :text => KDE.i18n("&Connect to ICS") do
      connect_to_ics
    end
    regular_action :disconnect, :icon => 'network-disconnect',
                                :text => KDE.i18n("&Disconnect from ICS") do
      if @connection
        @connection.close
        @connection = nil
      end
    end
    
    regular_action :flip, :icon => 'object-rotate-left',
                          :text => KDE.i18n("F&lip") do
      @table.flip(! @table.flipped?)
    end
                  
  end
  
  def startup
    scene = Scene.new
    @table = Table.new scene, @loader, self
    @controller = Controller.new(@table)
    @table.observe(:reset) do |match|
      update_game_actions(match)
    end

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
  
  def connect_to_ics
    protocol = ICS::Protocol.new(:debug)
    @connection = ICS::Connection.new('freechess.org', 23)
    protocol.add_observer ICS::AuthModule.new(@connection, 'ujjajja', '')
    protocol.add_observer ICS::StartupModule.new(@connection)
    protocol.link_to @connection

    protocol.observe :text do |text|
      @console.append(text)
    end

    @console.observe :input do |text|
      @connection.send_text text
    end

    handler = ICS::MatchHandler.new(@controller, protocol)

    @connection.start
  end
  
  def new_game(match)
    setup_single_player(match)
    @controller.reset(match)
  end
  
  def setup_single_player(match)
    @controller.color = match.game.players.first
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

class DummyPlayer
  include Observer
  include Player
  
  attr_reader :color
  attr_accessor :name
  
  def initialize(color)
    @color = color
  end
end
