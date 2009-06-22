require 'qtutils'
require 'board/board'
require 'board/pool'
require 'board/table'
require 'board/scene'
require 'history'
require 'controller'

class MainWindow < KDE::XmlGuiWindow
  include ActionHandler
  
  Theme = Struct.new(:pieces, :board, :layout)
  
  def initialize(loader, game)
    super nil
    
    @loader = loader
    
    load_board(game)
    
    setup_actions
    setupGUI
  end

private

  def setup_actions
    std_action :open_new do
      puts "new game"
    end
    std_action :quit, :slot => :close
    regular_action :back, :icon => 'go-previous', 
                          :text => KDE.i18n("&Back") do
      @controller.back
    end
    regular_action :forward, :icon => 'go-next', 
                             :text => KDE.i18n("&Forward") do
      @controller.forward
    end
                  
  end
  
  def load_board(game)
    config = KDE::Global.config.group('themes')
    
    theme = Theme.new
    theme.pieces = @loader.
      get_matching((game.keywords || []) + %w(pieces)).
      new(:game => game, :shadow => true)
    theme.board = @loader.
      get_matching(%w(board), game.keywords || []).
      new(:game => game)
    theme.layout = @loader.
      get_matching(%w(layout), game.keywords || []).
      new(game)
    
    scene = Scene.new
    
    state = game.state.new.tap {|s| s.setup }
    
    field = AnimationField.new(20)
    board = Board.new(scene, theme, game)
    pools = if game.respond_to? :pool
      game.players.inject({}) do |res, player|
        res[player] = Pool.new(scene, theme, game)
        res
      end
    else
      {}
    end
    clock_class = @loader.get_matching(%w(clock))
    clocks = game.players.inject({}) do |res, player|
      res[player] = clock_class.new(scene)
      res
    end
    
    elements = { :board => board,
                 :pools => pools,
                 :clocks => clocks }
    table = Table.new scene, theme, self, elements

    history = History.new(state)
    @controller = Controller.new(scene, elements, game, history)
    
    self.central_widget = table
  end
end
