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

class MainWindow < KDE::XmlGuiWindow
  include ActionHandler

  def initialize(loader, game)
    super nil
    
    @loader = loader
    @default_game = game
    
    load_board(game)
    
    setup_actions
    setupGUI
  end

private

  def setup_actions
    std_action(:open_new) { new_game(@default_game) }
    std_action :quit, :slot => :close
    regular_action :back, :icon => 'go-previous', 
                          :text => KDE.i18n("&Back") do
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
      puts "disconnect"
    end
    
    regular_action :flip, :icon => 'object-rotate-left',
                          :text => KDE.i18n("F&lip") do
      @table.flip(! @table.flipped?)
    end
                  
  end
  
  def load_board(game)
    scene = Scene.new
    @table = Table.new scene, @loader, self
    @controller = Controller.new(@table)

    movelist = @loader.get_matching(%w(movelist)).new(@controller)
    movelist_dock = Qt::DockWidget.new(self)
    movelist_dock.widget = movelist
    movelist_dock.window_title = KDE.i18n("Move list")
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

    new_game(game)
    
    self.central_widget = @table
  end
  
  def connect_to_ics
    protocol = ICS::Protocol.new(:debug)
    c = ICS::Connection.new('freechess.org', 23)
    protocol.add_observer ICS::AuthModule.new(c, 'ujjajja', '')
    protocol.add_observer ICS::StartupModule.new(c)
    protocol.link_to c

    protocol.observe :text do |text|
      @console.append(text)
    end

    @console.observe :input do |text|
      c.send_text text
    end

    handler = ICS::MatchHandler.new(@controller, protocol)

    protocol.observe :creating_game do |data|
      puts "CREATING GAME: #{data.inspect}"
    end

    c.start
  end
  
  def new_game(game)
    @controller.color = game.players.first
    opponents = game.players[1..-1].map do |color|
      DummyPlayer.new(color)
    end
    opponents.each do |p| 
      @controller.add_controlled_player(p)
    end

    match = Match.new(game)
    @controller.controlled.values.each do |p|
      match.register(p)
    end
    @controller.controlled.values.each do |p|
      match.start(p)
    end
    
    @controller.reset(match)
  end
end

class DummyPlayer
  include Observer
  
  attr_reader :color
  
  def initialize(color)
    @color = color
  end
end
