require 'test/unit'
require 'games/chess/chess'
require 'helpers/validation_helper'

class ChessPerformMovesTest < Test::Unit::TestCase
  include ValidationHelper
  
  def setup
    @board = Chess::Board.new(Point.new(8, 8))
    @state = Chess::State.new(@board, Chess::Move, Chess::Piece)
    @validate = Chess::Validator.new(@state)
    
    @state.setup
  end
  
  def test_simple_move
    execute 6, 7, 5, 5
    
    assert_equal Chess::Piece.new(:white, :knight), 
                 @board[Point.new(5, 5)]
    assert_nil @state.board[Point.new(6, 7)]
    assert_nil @state.en_passant_square
    assert_equal :black, @state.turn
  end
  
  def test_en_passant_push
    execute 4, 6, 4, 4
    
    assert_equal Chess::Piece.new(:white, :pawn),
                 @board[Point.new(4, 4)]
    assert_nil @state.board[Point.new(4, 6)]
    assert_equal Point.new(4, 5), @state.en_passant_square
    assert_equal :black, @state.turn
  end
  
  def test_en_passant_capture
    execute 4, 6, 4, 4
    execute 0, 1, 0, 2
    execute 4, 4, 4, 3
    execute 3, 1, 3, 3
    execute 4, 3, 3, 2 
    
    assert_equal Chess::Piece.new(:white, :pawn),
                 @board[Point.new(3, 2)]
    assert_nil @board[Point.new(4, 3)]
    assert_nil @board[Point.new(3, 3)]
  end
  
  def test_promotion
    execute 0, 6, 0, 4 # a4
    execute 1, 1, 1, 3 # b5
    execute 0, 4, 1, 3 # axb5
    execute 0, 1, 0, 2 # a6
    execute 1, 3, 0, 2 # bxa6
    execute 1, 0, 2, 2 # Nc6
    execute 0, 2, 0, 1 # a7
    execute 0, 0, 1, 0 # Rb8
    execute 0, 1, 0, 0, :promotion => :rook
    
    assert_equal Chess::Piece.new(:white, :rook),
                 @board[Point.new(0, 0)]
  end
  
  def test_promotion_capture
    execute 0, 6, 0, 4 # a4
    execute 1, 1, 1, 3 # b5
    execute 0, 4, 1, 3 # axb5
    execute 0, 1, 0, 2 # a6
    execute 1, 3, 0, 2 # bxa6
    execute 1, 0, 2, 2 # Nc6
    execute 0, 2, 0, 1 # a7
    execute 0, 0, 1, 0 # Rb8
    execute 0, 1, 1, 0, :promotion => :bishop
    
    assert_equal Chess::Piece.new(:white, :bishop),
                 @board[Point.new(1, 0)]
  end
  
  def test_king_side_castling
    execute 6, 7, 5, 5
    execute 6, 0, 5, 2
    execute 4, 6, 4, 4
    execute 0, 1, 0, 2
    execute 5, 7, 4, 6
    execute 0, 2, 0, 3
    execute 4, 7, 6, 7
    
    assert_piece :white, :king, 6, 7
    assert_piece :white, :rook, 5, 7
    assert_no_piece 4, 7
    assert_no_piece 7, 7
  end
  
  def test_queen_side_castling
    @board[Point.new(1, 7)] = nil
    @board[Point.new(2, 7)] = nil
    @board[Point.new(3, 7)] = nil
    
    execute 4, 7, 2, 7
    
    assert_piece :white, :king, 2, 7
    assert_piece :white, :rook, 3, 7
    assert_no_piece 0, 7
    assert_no_piece 4, 7
  end
  
  def test_black_king_side_castling
    @board[Point.new(5, 0)] = nil
    @board[Point.new(6, 0)] = nil
    
    execute 0, 6, 0, 5
    execute 4, 0, 6, 0
    
    assert_piece :black, :king, 6, 0
    assert_piece :black, :rook, 5, 0
    assert_no_piece 4, 0
    assert_no_piece 7, 0
  end
  
  def test_black_queen_side_castling
    @board[Point.new(1, 0)] = nil
    @board[Point.new(2, 0)] = nil
    @board[Point.new(3, 0)] = nil
    
    execute 0, 6, 0, 5
    execute 4, 0, 2, 0
    
    assert_piece :black, :king, 2, 0
    assert_piece :black, :rook, 3, 0
    assert_no_piece 0, 0
    assert_no_piece 4, 0
  end
end
