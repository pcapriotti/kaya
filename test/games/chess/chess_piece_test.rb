require 'test/unit'
require 'games/chess/piece'

class ChessPieceTest < Test::Unit::TestCase
  def test_fields
    piece = ChessPiece.new(:white, :bishop)
    assert_equal :bishop, piece.type
    assert_equal :white, piece.color
  end
  
  def test_equality
    assert_equal ChessPiece.new(:white, :bishop), ChessPiece.new(:white, :bishop)
    assert_not_equal ChessPiece.new(:white, :bishop), ChessPiece.new(:black, :bishop)
    assert_not_equal ChessPiece.new(:white, :bishop), ChessPiece.new(:white, :rook)
    assert_not_equal ChessPiece.new(:white, :queen), ChessPiece.new(:black, :king)
  end
end