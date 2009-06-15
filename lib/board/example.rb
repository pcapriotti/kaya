$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'korundum4'
require 'board/table'
require 'themes/loader'
require 'controller'
require 'games/games'
require 'history'

description = "KDE Board Game Suite"
version = "1.5"
about = KDE::AboutData.new("tagua", "Tagua", KDE.ki18n("Tagua"),
    version, KDE.ki18n(description),KDE::AboutData::License_GPL,KDE.ki18n("(C) 2003 whoever the author is"))

about.addAuthor(KDE.ki18n("author1"), KDE.ki18n("whatever they did"), "email@somedomain")
about.addAuthor(KDE.ki18n("author2"), KDE.ki18n("they did something else"), "another@email.address")

KDE::CmdLineArgs.init(ARGV, about)

app = KDE::Application.new

class Scene < Qt::GraphicsScene
  def initialize
    super
  end
end

theme_loader = ThemeLoader.new
theme = Struct.new(:pieces, :background).new
theme.pieces = theme_loader.get('Celtic')
theme.background = theme_loader.get('Default', Point.new(8, 8))

chess = Game.get(:chess)

scene = Qt::GraphicsScene.new

state = chess.state.new
state.setup

board = Board.new(scene, theme, chess, state)
board.observe :new_move do |data|
  move = data[:move]
  puts "execute #{move.src.x}, #{move.src.y}, #{move.dst.x}, #{move.dst.y}"
end

table = Table.new(scene, board)
table.size = Qt::Size.new(500, 500)

history = History.new(state)
controller = Controller.new(board, history)

table.show

app.exec
