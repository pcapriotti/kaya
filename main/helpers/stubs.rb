class GeneralMock
  attr_reader :calls
  
  def initialize
    @calls = []
  end
  
  def method_missing(method, *args)
    @calls << [method, args]
  end
end