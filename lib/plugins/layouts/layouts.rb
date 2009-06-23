def require_relative(file)
  require File.join(File.dirname(__FILE__), file)
end

require_relative 'cool/cool'
