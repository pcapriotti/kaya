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
          res << lambda { @board.add_piece p, new_piece } unless old_item && new_piece.name == old_item.name
        else
          res << lambda { @board.remove_item p } if old_item
        end
      end
            
      group(*res)
    end
    
    def forward(state, move)
      warp state
    end
  end
end
