require 'plugins/plugin'

class SimpleMoveList < Qt::ListView
  include Plugin
  include Observer
  
  plugin :name => 'Simple Move List',
         :keywords => %w(movelist)
         
  class LinearHistoryModel < Qt::StringListModel
    include Observer
    include Observable
    
    def initialize(match)
      super([])
      @history = match.history
      @serializer = match.game.serializer.new(:compact)
      
      @history.add_observer(self)
      
      insert_rows(0, @history.size)
      (0...@history.size).each do |i|
        update_row(i)
      end
    end
    
    def on_new_move
      if @history.size > rowCount
        insert_rows(rowCount, @history.size - rowCount)
      else
        remove_rows(@history.size, rowCount - @history.size)
      end
      update_row(@history.current)
      on_current_changed
    end

    def on_current_changed
      fire :change_current => index(@history.current, 0)
    end
    
    def move(i)
      if i == 0
        'Mainline'
      else
        state = @history[i - 1].state
        move = @history[i].move
        san = @serializer.serialize(move, state)
        
        count = i / 2 + 1
        dots = if i % 2 == 0
          '.'
        else
          '...'
        end
        
        "#{count}#{dots} #{san}"
      end
    end
    
    def update_row(i)
      set_data(index(i, 0), move(i), Qt::DisplayRole)
    end
    
    def flags(index)
      if index.isValid
        Qt::ItemIsSelectable | Qt::ItemIsEnabled
      else
        Qt::NoItemFlags
      end
    end
  end
  
  def initialize(controller, opts = {})
    super(controller.table)
    @controller = controller
    self.font = opts[:font] if opts[:font]
    
    @controller.table.add_observer(self)
  end
  
  def on_reset(match)
    if match.game.respond_to?(:serializer)
      self.model = LinearHistoryModel.new(match)
      model.observe(:change_current) do |current|
        selection_model.select(current, 
          Qt::ItemSelectionModel::ClearAndSelect)
      end
      sig = 'selectionChanged(QItemSelection, QItemSelection)'
      selection_model.on(sig) do |selected, deselected|
        @controller.go_to(selected.indexes.first.row)
      end
    else
      self.model = nil
    end
  end
end

