class ThemeLoader
  BASE_DIR = File.dirname(__FILE__)
  
  class NoThemeFound < Exception
  end
  
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
  
  def get_matching(required, optional = [])
    themes = @themes.values.
      reject {|x| not x.matches?(required) }.
      sort_by {|x| x.score(optional) }
    raise NoThemeFound if themes.empty?
    themes.last
  end
end
