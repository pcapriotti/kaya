require 'qtutils'

class NewGame < KDE::Dialog
  def initialize(parent, blk)
    super(parent)
    self.caption = KDE.i18n("New game")
    self.buttons = KDE::Dialog::Ok | KDE::Dialog::Cancel
    
    widget = Qt::Widget.new(self)
    
    @games = KDE::ComboBox.new(widget) do
      self.editable = false
      Game.each do |id, game|
        add_item(game.class.data(:name), id.to_s)
      end
    end
    
    layout = Qt::VBoxLayout.new(widget)
    layout.add_widget(@games)
    
    self.main_widget = widget
    on(:okClicked) do
      index = @games.current_index
      game = @games.item_data(index).toString.to_sym
      blk[Game.get(game)]
    end
  end
end
