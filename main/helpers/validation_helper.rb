module ValidationHelper
  def unpack_move(*args)
    opts = {}
    if args.last.instance_of? Hash
      opts = args.last
      args = args[0...-1]
    end
    
    case args.size
    when 1
      args.first
    when 2
      Chess::Move.new(*(args + [opts]))
    when 4
      Chess::Move.new(*(args.to_enum(:each_slice, 2).map{|x| Point.new(*x) } + [opts]))
    else
      raise ArgumentError.new("Could not unpack move using #{args.size} parameters")
    end
  end
  
  def assert_valid(*args)
    assert @validate[unpack_move(*args)]
  end
  
  def assert_not_valid(*args)
    assert ! @validate[unpack_move(*args)]
  end
  
  def execute(*args)
    move = unpack_move(*args)
    assert @validate[move]
    @state.perform! move
  end
end
