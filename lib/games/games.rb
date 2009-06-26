require 'factory'
require 'plugins/loader'

class Game
  GAMES = { }
  LOADER = PluginLoader.new

  def self.load_all(directory = nil)
    klasses = { }
    LOADER.get_all_matching(:game).each do |game|
      klasses[game.data(:id)] = game
    end
    
    klasses.values.each {|klass| register_game(klasses, klass) }
  end

  def self.dummy
    # dummy is chess for the moment
    get(:chess)
  end

  def self.get(name)
    GAMES[name]
  end
  
  def self.each(&blk)
    GAMES.each(&blk)
  end
 
  private
  
  def self.register_game(klasses, klass)
    unless Game.get(klass.data(:id))
      (klass.data(:depends) || []).each do |dep|
        depklass = klasses[dep] or
          raise "Invalid dependency #{dep} for game #{klass.plugin_name}"
        register_game(klasses, depklass)
        klass.instance_eval do
          define_method(dep) { Game.get(dep) }
        end
      end
      GAMES[klass.data(:id)] = klass.new
    end
  end
end

