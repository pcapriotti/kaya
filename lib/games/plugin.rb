require 'games/games'

module Games

module Plugin
  module ModuleMethods
    def included(base)
      if base.class == Module
        base.extend ModuleMethods
      else
        base.extend ClassMethods
      end
    end
  end
  
  module ClassMethods
    def game(name)
      Games.add(name, self)
    end
  end
  
  extend ModuleMethods
end


end
