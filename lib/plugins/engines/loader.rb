require 'factory'

class EngineLoader
  include Plugin
  include Enumerable
  
  class Entry < Factory
    attr_reader :name
    attr_reader :game
    attr_reader :protocol
    attr_reader :workdir
    attr_reader :path
  
    def initialize(data)
      loader = PluginLoader.new
      plugin = loader.get_all_matching(:engine).find do |e|
        e.data(:protocol) == data[:protocol]
      end
      fact = lambda do |color, match|
        plugin.new(@path, @name, color, match, 
                   :workdir => @workdir)
      end
      super(&fact)
      
      @name = data[:name]
      @game = Game.get(data[:game])
      @protocol = data[:protocol]
      @workdir = data[:workdir]
      @path = data[:path]
    end
    
    def self.load(name, group)
      new :name => name,
          :game => group.read_entry('game').to_sym,
          :path => group.read_entry('path'),
          :protocol => group.read_entry('protocol'),
          :workdir => group.read_entry('workdir')
    end
    
    def save(group)
      group.write_entry('game', @game.class.data(:id).to_s)
      group.write_entry('path', @path)
      group.write_entry('protocol', @protocol)
      group.write_entry('workdir', @workdir)
    end
  end
  
  plugin :name => 'Default Engine Loader',
         :interface => :engine_loader
         
  def initialize
    reload
  end

  def reload
    @entries = { }
    config = KDE::Global.config.group("Engines")
    engine_groups = config.group_list
    engine_groups.each do |engine_group|
      entry = Entry.load(engine_group, config.group(engine_group))
      @entries[entry.name] = entry
    end
  end
  
  def update_entries(entries)
    @entries = entries.dup
    
    config = KDE::Global.config.group("Engines")
    config.delete_group
    @entries.each do |name, engine|
      group = config.group(name)
      engine.save(group)
    end
    config.sync
  end
  
  def [](name)
    @entries[name]
  end

  def find_by_game(game)
    @entries.select do |name, e|
      e.game == game
    end
  end
  
  def each(&blk)
    @entries.each(&blk)
  end
  
  def size
    @entries.size
  end
  
  def engine
    Entry
  end
end
