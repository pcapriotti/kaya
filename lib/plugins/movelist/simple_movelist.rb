require 'plugins/plugin'

class SimpleMoveList < Qt::ListView
  include Plugin
  
  plugin :name => 'Simple Move List',
         :keywords => %w(movelist)
  
  def initialize(parent, history, game, opts = {})
    super(parent)
#     self.model = Qt::StringListModel.new
#     @history.add_observer(self)
#     moves = (1...@history.size).map do |index|
#       move(index)
#     end
#     self.model.set_string_list(moves)

    history.serializer = game.serializer.new(:compact)
    self.model = history
    
#     if opts[:font]
      self.font = opts[:font] if opts[:font]
#     else
#       f = font
#       f.point_size = 16
#       self.font = f
#     end
  end
  
#   def on_added(index)
#     index -= 1
#     self.model.remove_rows(index, @history.size - index - 1)
#     self.model.insert_rows(index, 1)
#     self.model.set_data(self.model.index(index, 0), 
#                         move(index), 
#                         Qt::DisplayRole)
#   end
  
#   private
  
#   def move(index)
#     state = @history[index].state
#     move = @history[index+ 1].move
#     san = @serializer.serialize(move, state)
#     
#     count = index/ 2 + 1
#     dots = if index% 2 == 0
#       '.'
#     else
#       '...'
#     end
#     
#     "#{count}#{dots} #{san}"
#   end
end

