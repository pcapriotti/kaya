$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'korundum4'
require 'table'
require 'themes/fantasy/fantasy'
require 'themes/squares/default'

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

theme = Struct.new(:pieces, :background).new
theme.pieces = FantasyTheme.new
theme.background = DefaultBackground.new(Point.new(8, 8))

chessboard = Chess::Board.new(Point.new(8, 8))
state = Chess::State.new(chessboard)
state.setup

scene = Qt::GraphicsScene.new

board = Board.new(scene, theme, state)
table = Table.new(scene, board)

table.show

app.exec
