module ValidationHelper
  def unpack_move(*args)
    case args.size
    when 1
      args.first
    when 2
      Chess::Move.new(*args)
    when 4
      Chess::Move.new(*args.to_enum(:each_slice, 2).map{|x| Point.new(*x) })
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
end
