require 'test/unit'
require 'games/chess/piece'

class ChessPieceTest < Test::Unit::TestCase
  def test_fields
    piece = Chess::Piece.new(:white, :bishop)
    assert_equal :bishop, piece.type
    assert_equal :white, piece.color
  end
  
  def test_equality
    assert_equal Chess::Piece.new(:white, :bishop), Chess::Piece.new(:white, :bishop)
    assert_not_equal Chess::Piece.new(:white, :bishop), Chess::Piece.new(:black, :bishop)
    assert_not_equal Chess::Piece.new(:white, :bishop), Chess::Piece.new(:white, :rook)
    assert_not_equal Chess::Piece.new(:white, :queen), Chess::Piece.new(:black, :king)
  end
end