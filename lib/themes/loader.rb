class ThemeLoader
  BASE_DIR = File.dirname(__FILE__)
  
  def initialize
    # load all ruby files in subdirectories
    Dir[File.join(BASE_DIR, '*')].each do |f|
      if File.directory?(f)
        Dir[File.join(f, '*.rb')].each do |rb_file|
          require rb_file
        end
      end
    end
    
    @themes = {}
    ObjectSpace::each_object(Class) do |k|
      if k.include? Theme
        @themes[k.theme_name] = k
      end
    end
    
  end
  
  def each(&blk)
    @themes.each_value(&blk)
  end
  
  def get(name, game, opts = { })
    @themes[name].new(opts.merge(:game => game))
  end
end
