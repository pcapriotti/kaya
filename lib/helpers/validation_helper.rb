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
      @state.move_factory.new(*(args + [opts]))
    when 4
      @state.move_factory.new(*(args.to_enum(:each_slice, 2).map{|x| Point.new(*x) } + [opts]))
    else
      raise ArgumentError.new("Could not unpack move using #{args.size} parameters")
    end
  end
  
  def unpack_point(*args)
    case args.size
    when 1
      args.first
    when 2
      Point.new(*args)
    end
  end
  
  def assert_valid(*args)
    move = unpack_move(*args)
    assert @validate[move]
    yield move if block_given?
  end
  
  def assert_not_valid(*args)
    assert ! @validate[unpack_move(*args)]
  end
  
  def assert_piece(color, type, *point)
    p = unpack_point(*point)
    piece = @board[p]
    exp = @state.piece_factory.new(color, type)
    assert_not_nil piece, "#{exp} expected on #{p}, nothing found"
    assert_equal exp, piece, "#{exp} expected on #{p}, #{piece} found"
    yield piece if block_given?
  end
  
  def assert_no_piece(*point)
    assert_nil @board[unpack_point(*point)]
  end
  
  def execute(*args)
    move = unpack_move(*args)
    assert @validate[move]
    @state.perform! move
  end
  
  def assert_pool(color, type, number)
    piece = @state.piece_factory.new(color, type)
    assert_equal number, @state.pool(color).pieces[piece]
  end
end
