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
      (@theme_data || {})[:name] || name
    end
  end
  
  extend ModuleMethods
  
  def item(scene, *args)
    pixmap(*args).to_item(scene)
  end
end
