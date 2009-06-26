require 'factory'

class EngineLoader
  include Plugin
  
  class Entry < Factory
    attr_reader :name
    attr_reader :game
  
    def initialize(name, game, &blk)
      super(&blk)
      @name = name
      @game = game
    end
    
    def self.load(loader, name, group)
      game = Game.get(group.read_entry('game').to_sym)
      path = group.read_entry('path')
      protocol = group.read_entry('protocol')
      workdir = group.read_entry('workdir')
      
      engine_plugin = loader.get_all_matching(:engine).find do |e|
        e.data(:protocol) == protocol
      end
      
      new(name, game) do |color, match|
        engine_plugin.new(path, name, color, match)
      end
    end
  end
  
  plugin :name => 'Default Engine Loader',
         :interface => :engine_loader
         
  def initialize(loader)
    @loader = loader
    reload
  end

  def reload
    @entries = { }
    config = KDE::Global.config.group("Engines")
    engine_groups = config.group_list
    engine_groups.each do |engine_group|
      entry = Entry.load(@loader, engine_group, config.group(engine_group))
      @entries[entry.name] = entry
    end
  end
  
  def [](name)
    @entries[name]
  end
  
  def find_by_game(game)
    @entries.select do |name, e|
      e.game == game
    end
  end
end
