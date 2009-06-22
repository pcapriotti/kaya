module Theme
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
    def theme(args)
      @theme_data = args
    end
    
    def theme_name
      @theme_data[:name] if @theme_data
    end
    
    def matches?(keywords)
      keywords.all? do |k|
        @theme_data[:keywords].include? k
      end
    end
    
    def score(keywords)
      (@theme_data[:keywords] & keywords).size
    end
  end
  
  extend ModuleMethods
end
