require 'animations'

module Chess
  class Animator
    include Animations
    
    def initialize(board)
      @board = board
    end
  
    def warp(state)
      res = []
      
      state.board.each_square do |p|
        new_piece = state.board[p]
        old_item = @board.items[p]
        
        if new_piece
          res << Animation.new('insert') { @board.add_piece p, new_piece } unless old_item && new_piece.name == old_item.name
        else
          res << Animation.new('remove') { @board.remove_item p } if old_item
        end
      end

      group(*res)
    end
    
    def forward(state, move)
#       extra = if move.type == :king_side_castling
#         rook_move = move.dst + Point.new(1, 0), move.dst - Point.new(1, 0)
#         rook = @board.move_item()
#         movement(rook, 
#       end
      
      sequence group(disappear_on!(move.dst), move!(move.src, move.dst)),
               warp(state)
    end
  end
end
