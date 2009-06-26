class Factory
  attr_reader :component

  def initialize(klass = nil, &blk)
    @blk = blk
    @component = klass
  end
  
  def new(*args)
    @blk[*args]
  end
end
