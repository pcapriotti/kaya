module Validable
  attr_writer :valid
  
  def valid?
    @valid
  end
  
  def validated?
    @valid != nil
  end
  
  def validate
    if validated?
      valid?
    else
      self.valid = yield self
    end
  end
end
