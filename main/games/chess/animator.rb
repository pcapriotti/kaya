require 'animations'

module Chess
  class Animator
    include Animations
    
    def initialize(board)
      @board = board
    end
  
    def warp(state, opts = { :instant => true })
      res = []
      
      state.board.each_square do |p|
        new_piece = state.board[p]
        old_item = @board.items[p]
        
        if new_piece
          if not old_item
            res << appear_on!(p, new_piece, opts)
          elsif new_piece.name != old_item.name
            res << morph_on!(p, new_piece, opts)
          end
        else
          res << disappear_on!(p, opts) if old_item
        end
      end

      group(*res)
    end
    
    def forward(state, move)
      capture = disappear_on! move.dst
      actual_move = move! move.src, move.dst
      extra = if move.type == :king_side_castling
        move! move.dst + Point.new(1, 0), move.dst - Point.new(1, 0)
      elsif move.type == :queen_side_castling
        move! move.dst - Point.new(2, 0), move.dst + Point.new(1, 0)
      end
      
      rest = warp(state, :instant => false)
      main = group(capture, actual_move, extra)
      
      sequence(main, rest)
    end
    
    def back(state, move)
      piece = state.board[move.dst]
      restore_piece = unless piece
        appear_on! move.dst, piece
      end
      
      actual_move = move! move.dst, move.src
      rest = warp(state, :instant => false)
      main = group(restore_piece, actual_move)
      
      sequence(main, rest)
    end
  end
end
