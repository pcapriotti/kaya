$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'qtutils'
require 'board/table'
require 'themes/loader'
require 'games/chess/chess'
require 'controller'
require 'history'
require 'ics/connection'
require 'ics/protocol'
require 'console'

protocol = ICS::Protocol.new
c = ICS::Connection.new('freechess.org', 5000, protocol)
protocol.add_observer ICS::AuthModule.new(c, 'guest', '')
protocol.add_observer ICS::StartupModule.new(c)

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

chess = Chess::Game.new

scene = Qt::GraphicsScene.new

state = chess.new_state
state.setup

board = Board.new(scene, theme, chess, state)


table = Table.new(scene, board)
table.size = Qt::Size.new(500, 500)

history = History.new(state)
controller = Controller.new(board, history)

table.show

console = Console.new(nil)
console.show

protocol.observe :text do |text|
  console.run_later { console.append(text) }
end

console.observe :input do |text|
  c.send(text)
end

board.observe :new_move do |data|
  move = data[:move]
  m = ('a'[0] + move.src.x).chr +
    (8 - move.src.y).to_s +
    ('a'[0] + move.dst.x).chr +
    (8 - move.dst.y).to_s
  puts m
  c.send m
end

protocol.observe :style12 do |style12|
  puts style12.inspect
end

c.start

app.exec
