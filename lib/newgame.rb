require 'qtutils'

class NewGame < KDE::Dialog
  include Observable
  
  def initialize(parent, engine_loader)
    super(parent)
    self.caption = KDE.i18n("New game")
    self.buttons = KDE::Dialog::Ok | KDE::Dialog::Cancel
    
    @widget = Qt::Widget.new(self)
    
    @engine_loader = engine_loader
    @games = KDE::ComboBox.new(@widget) do
      self.editable = false
      Game.each do |id, game|
        add_item(game.class.data(:name), id.to_s)
      end
    end
    @players = { }

    @layout = Qt::VBoxLayout.new(@widget)
    @layout.add_widget(@games)

    @games.on('currentIndexChanged(int)') do |index|
      update_players(index)
    end
    
    update_players(@games.current_index)
    
    self.main_widget = @widget
    
    on(:okClicked) do
      engines = { }
      humans = []
      g = game
      g.players.each do |player|
        # iterate over the player array to preserve order
        combo = @players[player]
        data = combo.item_data(combo.current_index).to_a
        if data.first == 'engine'
          engine_name = data[1]
          engines[player] = engine_loader[engine_name]
        else
          humans << player
        end
      end
      fire :ok => {
        :game => game,
        :engines => engines,
        :humans => humans }
    end
  end
  
  def update_players(index)
    @players.each {|player, combo| combo.dispose }
    @players = { }
    g = game(index)
    engines = @engine_loader.find_by_game(g)
    g.players.each do |player|
      combo = KDE::ComboBox.new(@widget) do
        self.editable = false
        add_item(KDE.i18n('Human'), Qt::Variant.new(['human']))
      end
      engines.each do |id, engine|
        combo.add_item(engine.name, Qt::Variant.new(['engine', engine.name]))
      end
      @players[player] = combo
      @layout.add_widget(combo)
    end
  end
  
  def game(index = nil)
    index = @games.current_index if index.nil?
    game_id = @games.item_data(index).toString.to_sym
    Game.get(game_id)
  end
end
