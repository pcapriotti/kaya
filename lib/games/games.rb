require 'factory'

class Game
  GAMES = { }
  LOADING = { }
  LoadableGame = Struct.new(:deps, :defn)

  def self.load_all(directory = nil)
    directory ||= File.dirname(__FILE__)
    Dir[File.join(directory, '*')].each do |f|
      if File.directory?(f)
        main = File.join(f, 'main.rb')
        load main if File.exist?(main)
      end
    end
    
    # register games
    LOADING.each do |name, game|
      register_game(name, game)
    end
  end

  def self.dummy
    # dummy is chess for the moment
    get(:chess)
  end

  def self.get(name)
    GAMES[name]
  end

  def self.add(name, deps = [], &defn)
    if Game.get(name) or LOADING[name]
      raise "The game #{name} is already defined"
    end
    LOADING[name] = LoadableGame.new(deps, defn)
  end
  
  def extend(fields)
    clone.tap do |x|
      x.add_fields(fields)
    end
  end

  def initialize(fields)
    add_fields(fields)
  end
  
  protected
  
  def add_fields(fields)
    fields.each do |field, value|
      case value
      when Proc
        f_method = "__#{field}"
        metaclass_eval do
          define_method(field) { Factory.new {|*args| send(f_method, *args) } }
          define_method(f_method, value)
        end
      else
        metaclass_eval do 
          define_method(field) { value }
        end
      end
    end
  end
  
  private
  
  def self.register_game(name, game)
    unless Game.get(name)
      deps = game.deps.map do |dep|
        Game.get(dep) || begin
          lgame = LOADING[dep] or 
            raise "Invalid dependency #{dep} for game #{name}"
          register_game(dep, lgame)
        end
      end
      GAMES[name] = game.defn[*deps]
    end
  end
end

