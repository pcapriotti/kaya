require 'qtutils'

class NewGame < KDE::Dialog
  include Observable
  
  def initialize(parent, 
                 engine_loader, 
                 current_game)
    super(parent)
    self.caption = KDE.i18n("New game")
    self.buttons = KDE::Dialog::Ok | KDE::Dialog::Cancel
    
    @widget = Qt::Widget.new(self)
    
    @engine_loader = engine_loader
    label = Qt::Label.new(KDE.i18n("&Game:"), @widget)
    @games = KDE::ComboBox.new(@widget) do
      self.editable = false
      Game.to_enum(:each).map do |id, g|
        [g.class.data(:name), id.to_s]
      end.sort.each do |name, id|
        add_item(name, id)
      end
    end
    
    label.buddy = @games
    hlayout = Qt::HBoxLayout.new
    hlayout.add_widget(label)
    hlayout.add_widget(@games)
    @players = { }

    @layout = Qt::VBoxLayout.new(@widget)
    @layout.add_layout(hlayout)

    current = (0...@games.count).
      map{|i| @games.item_data(i).toString }.
      index(current_game.class.data(:id).to_s)
    @games.current_index = current if current
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
    @player_widget.dispose if @player_widget
    @player_widget = Qt::Widget.new(@widget)
    layout = Qt::VBoxLayout.new(@player_widget)
    layout.margin = 0
    @layout.add_widget(@player_widget)
    
    @players = { }
    g = game(index)
    engines = @engine_loader.find_by_game(g)
    g.players.each do |player|
      label = Qt::Label.new(player.to_s.capitalize + ':', @player_widget)
      combo = KDE::ComboBox.new(@player_widget) do
        self.editable = false
        add_item(KDE.i18n('Human'), Qt::Variant.new(['human']))
      end
      engines.each do |id, engine|
        combo.add_item(engine.name, Qt::Variant.new(['engine', engine.name]))
      end
      @players[player] = combo
      
      hlayout = Qt::HBoxLayout.new
      hlayout.add_widget(label)
      hlayout.add_widget(combo)
      layout.add_layout(hlayout)
    end
  end
  
  def game(index = nil)
    index = @games.current_index if index.nil?
    game_id = @games.item_data(index).toString.to_sym
    Game.get(game_id)
  end
end
