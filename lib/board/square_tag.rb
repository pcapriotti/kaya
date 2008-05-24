module TaggableSquares
  TAGS_ZVALUE = -2
  
  def square_tag(name)
    define_method(name) do
      instance_variable_get("@#{name}")
    end
    
    define_method("#{name}=") do |val|
      instance_variable_set("@#{name}", val)
      if val
        add_item name, @theme.background.selection(@unit),
                 :pos => to_real(val),
                 :z => TAGS_ZVALUE
      else
        remove_item name
      end
    end
  end
end


