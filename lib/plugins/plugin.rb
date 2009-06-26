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
    def plugin(args)
      @plugin_data = args
    end
    
    def plugin_name
      @plugin_data[:name] if @plugin_data
    end
    
    def score(keywords)
      ((@plugin_data[:keywords] || []) & keywords).size
    end
    
    def implements?(iface)
      @plugin_data[:interface] == iface
    end
  end
  
  extend ModuleMethods
end
