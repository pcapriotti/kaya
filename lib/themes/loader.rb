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
      if k.include?(Theme) and k.theme_name
        @themes[k.theme_name] = k
      end
    end
    
  end
  
  def each(&blk)
    @themes.each_value(&blk)
  end
  
  def get(name, game, opts = { })
    instantiate @themes[name]
  end
  
  def get_matching(preferred, game, required, optional, opts = {})
    pref = @themes[preferred]
    return instantiate(pref, game, opts) if pref and pref.matches?(required)
    
    themes = @themes.values.reject {|x| not x.matches?(required) }.sort_by {|x| x.score(optional) }
    if themes.empty?
      raise "No valid theme"
    else
      instantiate themes.last, game, opts
    end
  end
  
  private
  
  def instantiate(theme, game, opts = {})
    theme.new(opts.merge(:game => game))
  end
end
