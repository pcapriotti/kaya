require 'test/unit'
require 'games/all'
require 'helpers/validation_helper'

class TestShogiSerializer < Test::Unit::TestCase
  include ValidationHelper

  def setup
    @game = Game.get(:shogi)
    @simple = @game.serializer.new(:simple)
    @compact = @game.serializer.new(:compact)
    @dec = @game.serializer.new(:decorated)
    @state = @game.state.new
    @validate = @game.validator.new(@state)
  end

  def test_simple_serialization
    @state.setup
    assert_equal '7g7f', serialize(@simple, 2, 6, 2, 5)
    @state.board[Point.new(2, 3)] = @game.piece.new(:black, :pawn)
    @state.board[Point.new(2, 6)] = nil
    assert_equal '7d7c+', serialize(@simple, 2, 3, 2, 2, :promote => true)
    
    piece = @game.piece.new(:black, :lance)
    @state.pool(:black).add(piece)
    assert_equal 'L*5e', serialize(@simple, 
      @game.move.drop(piece, Point.new(4, 4)))
  end
  
  def test_compact_serialization
    @state.setup
    assert_equal 'P-7f', serialize(@compact, 2, 6, 2, 5)
    
    @state.board[Point.new(4, 4)] = @game.piece.new(:black, :rook)
    assert_equal 'R-1e', serialize(@compact, 4, 4, 8, 4)
    assert_equal 'Rx5c+', serialize(@compact, 4, 4, 4, 2, :promote => true)
    
    @state.board[Point.new(4, 4)] = @game.piece.new(:black, :promoted_silver)
    assert_equal '+S-6e', serialize(@compact, 4, 4, 3, 4)
    
    @state.board[Point.new(4, 4)] = nil
    piece = @game.piece.new(:black, :gold)
    @state.pool(:black).add(piece)
    assert_equal 'G*5e', serialize(@compact, 
      @game.move.drop(piece, Point.new(4, 4)))
  end
  
  def test_compact_serialization_ambiguous
    @state.board[Point.new(0, 0)] = @game.piece.new(:black, :rook)
    @state.board[Point.new(8, 0)] = @game.piece.new(:black, :rook)
    @state.board[Point.new(0, 8)] = @game.piece.new(:black, :rook)
    @state.board[Point.new(8, 8)] = @game.piece.new(:black, :king)
    @state.board[Point.new(4, 4)] = @game.piece.new(:white, :king)
    assert_equal 'R9a-8a=', serialize(@compact, 0, 0, 1, 0, :promote => false)
    assert_equal 'R9a-9b+', serialize(@compact, 0, 0, 0, 1, :promote => true)
    
    @state.board[Point.new(1, 0)] = @game.piece.new(:black, :horse)
    assert_equal 'R9ax8a', serialize(@compact, 0, 0, 1, 0, :promote => false)
    
    @state.board[Point.new(0, 0)] = @game.piece.new(:black, :promoted_rook)
    assert_equal '+R9ax8a+', serialize(@compact, 0, 0, 1, 0, :promote => true)
  end
  
  def test_deserialize
    @state.setup
    assert_deserialize('P-7f', 2, 6, 2, 5)
    assert_deserialize('7g7f', 2, 6, 2, 5)
    execute 2, 6, 2, 5
    assert_deserialize('P-7d', 2, 2, 2, 3)
    execute 2, 2, 2, 3
    assert_deserialize('P-7e', 2, 5, 2, 4)
    execute 2, 5, 2, 4
    assert_deserialize('Px7e', 2, 3, 2, 4)
  end
  
  def test_deserialize_promote
    @state.setup
    @state.board[Point.new(6, 3)] = @game.piece.new(:black, :horse)
    
    assert_deserialize('Nx2b+', 6, 3, 7, 1, :promote => true)
  end
  
  def test_deserialize_promoted
    @state.setup
    @state.board[Point.new(4, 4)] = @game.piece.new(:black, :promoted_lance)
    
    assert_deserialize('+L-4e', 4, 4, 5, 4)
  end
  
  private
  
  def assert_deserialize(text, *args)
    move = unpack_move(*args)
    @game.validator.new(@state)[move]
    move2 = @compact.deserialize(text, @state)
    assert_equal move, move2
  end
end
