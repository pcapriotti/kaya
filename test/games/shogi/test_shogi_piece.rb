require 'test/unit'
require 'games/shogi/piece'

class TestShogiPiece < Test::Unit::TestCase
  def test_type_from_symbol
    assert_equal :lance, Shogi::Piece.type_from_symbol('L')
    assert_equal :promoted_silver, Shogi::Piece.type_from_symbol('+S')
    assert_equal :gold, Shogi::Piece.type_from_symbol('G')
  end
  
  def test_symbol
    assert_equal 'R', Shogi::Piece.symbol(:rook)
    assert_equal '+B', Shogi::Piece.symbol(:promoted_bishop)
    assert_equal '+N', Shogi::Piece.symbol(:promoted_horse)
    assert_equal 'G', Shogi::Piece.symbol(:gold)
  end
  
  def test_equality
    assert Shogi::Piece.new(:white, :rook).eql?(
      Shogi::Piece.new(:white, :rook))
  end
end
