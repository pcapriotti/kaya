require 'factory'

class Game
  GAMES = { }

  def self.dummy
    # dummy is chess for the moment
    get(:chess)
  end

  def self.get(name)
    GAMES[name]
  end

  def self.add(name, game)
    GAMES[name] = game
  end
  
  def initialize(fields)
    # @fields = fields
    add_fields(fields)
  end
  
  def extend(fields)
    dup.tap do |game|
      game.add_fields(fields)
    end
  end
  
  class Component
    attr_reader :klass, :blk
    def initialize(klass, blk)
      @klass = klass
      @blk = blk
    end
  end
  
  protected
  
  def add_fields(fields)
    fields.each do |field, value|
      case value
      when Proc
        f_method = "__#{field}"
        f = Factory.new {|*args| send(f_method, *args) }
        metaclass_eval do
          define_method(field) { f }
          define_method(f_method, value)
        end
      else
        metaclass_eval do
          define_method(field) { value }
        end
      end
    end
  end
end

