module Games

class Factory
  def initialize(&blk)
    @blk = blk
  end
  
  def new(*args)
    @blk[*args]
  end
end
