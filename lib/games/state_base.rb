module StateBase
  def new_piece(*args)
    @piece_factory.new(*args)
  end
  
  def new_move(*args)
    @move_factory.new(*args)
  end
end
