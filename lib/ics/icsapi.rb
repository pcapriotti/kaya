module ICS

class ICSApi
  PIECES = {
    'r' => :rook,
    'n' => :knight,
    'b' => :bishop,
    'q' => :queen,
    'k' => :king,
    'p' => :pawn }

  def initialize(game)
    @game = game
  end

  def new_state(opts)
    state = @game.state.new
    state.turn = opts[:turn]
    state.en_passant_square = 
      if opts[:en_passant] != -1
        Point.new(opts[:en_passant], 
                  state.turn == :white ? 
                  state.size.y - 3 : 2)
      end
    state.castling_rights.cancel_king(:white) unless opts[:wk_castling]
    state.castling_rights.cancel_queen(:white) unless opts[:wq_castling]
    state.castling_rights.cancel_king(:black) unless opts[:bk_castling]
    state.castling_rights.cancel_queen(:black) unless opts[:bq_castling]
    state
  end

  def new_piece(p)
    return nil if p == '-'
    color = p =~ /[a-z]/ ? :black : :white
    type = PIECES[p.downcase]
    @game.piece.new(color, type)
  end
end

end
