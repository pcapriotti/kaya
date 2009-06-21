require 'qtutils'
require 'board/board'
require 'board/pool'
require 'board/table'
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
      @board.fire :back
    end
    regular_action :forward, :icon => 'go-next', 
                             :text => KDE.i18n("&Forward") do
      @board.fire :forward
    end
                  
  end
  
  def load_board(game)
    config = KDE::Global.config.group('themes')
    
    theme = Theme.new
    theme.pieces = @loader.get_matching('Celtic', game,
      (game.keywords || []) + ['pieces'], [], :shadow => true)
    theme.board = @loader.get_matching(nil, game,
      ['board'], game.keywords || [])
    theme.layout = @loader.get_matching(nil, game,
      ['layout'], game.keywords || [])
    
    scene = Qt::GraphicsScene.new
    
    state = game.state.new.tap {|s| s.setup }
    
    field = AnimationField.new(20)
    @board = Board.new(scene, theme, game, state, field)
    if game.respond_to? :pool
      @pools = game.players.inject({}) do |res, player|
        res[player] = Pool.new(scene, theme, game, state.pool(player), field)
        res
      end
    end
    
    table = Table.new scene, theme, self,
      :board => @board,
      :pools => @pools
      
    self.central_widget = table

    history = History.new(state)
    controller = Controller.new(@board, history)
  end
end
