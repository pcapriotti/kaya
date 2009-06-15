require 'games/games'

module ICS

# Style 12 was designed by Daniel Sleator 
# (sleator+@cs.cmu.edu) Darooha@ICC
class Style12
  PATTERN = %r{
    ^<12>\s+                      # header
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([qkbnrpQKBNRP-]{8})\s+       # chessboard
    ([BW])\s+                     # black/white
    (-1|[0-7])\s+                 # passing pawn
    ([01])\s+                     # castle rights
    ([01])\s+                     # castle rights
    ([01])\s+                     # castle rights
    ([01])\s+                     # castle rights
    (-?\d+)\s+                    # 50 moves made
    (\d+)\s+                      # game number
    (\S+)\s+                      # white name
    (\S+)\s+                      # black name
    (-[1-4]|[0-2])\s+             # status
    (\d+)\s+                      # time
    (\d+)\s+                      # inc
    (\d+)\s+                      # w material
    (\d+)\s+                      # b material
    (-?\d+)\s+                    # w time
    (-?\d+)\s+                    # b time
    (\d+)\s+                      # move made
    (\S+)\s+                      # coordmove
    (\S+)\s+                      # time used
    (\S+)\s+                      # algmove
    ([0-1])                       # flip }x

  CHESSBOARD = 1
  TURN = 9
  EN_PASSANT = 10
  WHITE_KING_CASTLING = 11
  WHITE_QUEEN_CASTLING = 12
  BLACK_KING_CASTLING = 13
  BLACK_QUEEN_CASTLING = 14
  REVERSIBLE_MOVES = 15
  GAME_NUMBER = 16
  WHITE_PLAYER = 17
  BLACK_PLAYER = 18
  RELATION = 19
  STARTING_TIME = 20
  STARTING_INCREMENT = 21
  WHITE_TIME = 24
  BLACK_TIME = 25
  MOVE_ORDINAL = 26
  LAST_MOVE_VERBOSE = 27
  TIME_USED = 28
  LAST_MOVE = 29
  FLIP = 30

  def self.from_match(match, games)
    game_number = match[GAME_NUMBER].to_i
    current_game = games[game_number]
    game = if current_game
             current_game[:game]
           else
             Game.dummy
           end
    icsapi = ICSApi.new(game)

    state = 
      icsapi.new_state(:turn => match[TURN] == 'W' ? :white : :black,
                       :en_passant => match[EN_PASSANT].to_i,
                       :wk_castling => match[WHITE_KING_CASTLING].to_i == 1,
                       :wq_castling => match[WHITE_QUEEN_CASTLING].to_i == 1,
                       :bk_castling => match[BLACK_KING_CASTLING].to_i == 1,
                       :bq_castling => match[BLACK_QUEEN_CASTLING].to_i == 1)
    match[CHESSBOARD..CHESSBOARD+8].each_with_index do |row, i|
      row.split(//).each_with_index do |p, j|
        piece = icsapi.new_piece(p)
        state.board[Point.new(j, i)] = piece
      end
    end

    style12 = new(:state => state,
                  :game_number => match[GAME_NUMBER].to_i)
  end

  attr_reader :state

  def initialize(opts)
    @state = opts[:state]
    @game_number = opts[:game_number]
  end
end

end
