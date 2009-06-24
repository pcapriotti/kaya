require 'observer_utils'
require 'history'
require 'board/pool_animator'
require 'clock'
require 'interaction/match'

class Controller
  include Observer
  
  attr_reader :history
  attr_reader :color
  attr_reader :controlled
  
  def initialize(table)
    @table = table
    @scene = @table.scene

    @pools = { }
    @clocks = { }
    
    @field = AnimationField.new(20)
  end
  
  def each_element
    yield @board if @board
    @pools.each {|c, pool| yield pool }
    @clocks.each {|c, clock| yield clock }
  end
  
  def on_board_click(p)
    state = @match.state
    if @board.selection
      move = @match.game.policy.new_move(state, @board.selection, p)
      validate = @match.game.validator.new(state)
      if validate[move]
        perform! move
      end
      
      @board.selection = nil
    elsif @match.game.policy.movable?(state, p) and movable?(p)
      @board.selection = p
    end
  end
  
  def reset(match)
    @match = match
    @table.reset(match.game)
    @board = @table.elements[:board]
    @pools = @table.elements[:pools]
    @clocks = @table.elements[:clocks]
    
    @animator = @match.game.animator.new(@board)
    @board.reset(match.state.board)
    update_pools
    
    @clocks.each do |col, clock|
      clock.stop
    end
    
    @board.observe(:click) {|p| on_board_click(p) }
    @board.observe(:drag) {|data| on_board_drag(data) }
    @board.observe(:drop) {|data| on_board_drop(data) }
    @pools.each do |col, pool|
      pool.observe(:drag) {|data| on_pool_drag(col, data) }
      pool.observe(:drop) {|data| on_pool_drop(col, data) }
    end
    @clocks.each do |col, clock|
      clock.clock = Clock.new(300, 0, nil)
      clock.data = { :color => col }
    end
    @match.observe(:move) do |data|
      unless @controlled[data[:player].color] == data[:player]
        animate(:forward, data[:state], data[:move])
        @board.highlight(data[:move])
        @clocks[data[:old_state].turn].stop
        @clocks[data[:state].turn].stop
      end
    end
    
    @clocks[@match.game.players.first].active = true
  end
  
  def perform!(move, opts = {})
    col = @match.state.turn
    if @controlled[col] and @match.move(@controlled[col], move)
      animate(:forward, @match.state, move, opts)
      @board.highlight(move)
      
      @clocks[col].stop
      @clocks[@match.state.turn].start
    end
  end
  
#   def back
#     state, move = @history.back
#     animate(:back, state, move)
#     @board.highlight(@history.move)
#   rescue History::OutOfBound
#     puts "error: first move"
#   end
#   
#   def forward
#     state, move = @history.forward
#     animate(:forward, state, move)
#     @board.highlight(move)
#   rescue History::OutOfBound
#     puts "error: last move"
#   end
  
  def animate(direction, state, move, opts = {})
    anim = @animator.send(direction, state, move, opts)
    @field.run anim
    
    update_pools
  end
  
  def update_pools
    @pools.each do |col, pool|
      anim = pool.animator.warp(@match.state.pool(col))
      @field.run anim
    end
  end
  
  def on_board_drop(data)
    if data[:src]
      move = nil
      
      if data[:src] == data[:dst]
        @board.selection = data[:src]
      elsif data[:dst]
        # normal move
        move = @match.game.policy.new_move(
          @match.state, data[:src], data[:dst])
        validate = @match.game.validator.new(@match.state)
        validate[move]
      end
      
      if move and move.valid?
        @board.add_to_group data[:item]
        @board.lower data[:item]
        perform! move, :adjust => true
      else
        cancel_drop(data)
      end
    elsif data[:index] and data[:dst]
      # actual drop
      move = @match.game.policy.new_move(
        @match.state, nil, data[:dst], 
        :dropped => data[:item].name)
      validate = @match.game.validator.new(@match.state)
      if validate[move]
        @board.add_to_group data[:item]
        @board.lower data[:item]
        perform! move, :dropped => data[:item]
      else
        cancel_drop(data)
      end
    end
  end
  
  def on_board_drag(data)
    if @match.game.policy.movable?(@match.state, data[:src]) and 
       movable?(data[:src])
      @board.raise data[:item]
      @board.remove_from_group data[:item]
      @board.selection = nil
      @scene.on_drag(data)
    end
  end
  
  def on_pool_drag(c, data)
    if @match.game.policy.droppable?(@match.state, c, data[:index]) and 
       droppable?(c, data[:index])
       
       
      # replace item with a correctly sized one
      item = @board.create_piece(data[:item].name)
      @board.raise item
      @board.remove_from_group item
      anim = @pools[c].animator.remove_piece(data[:index])
      data[:item] = item
      data[:size] = @board.unit
      data[:pool_color] = c
      
      @scene.on_drag(data)
      
      @field.run anim
    end
  end
  
  def on_pool_drop(color, data)
    cancel_drop(data)
  end
  
  def cancel_drop(data)
    anim = if data[:index]
      # remove dragged item
      data[:item].remove
      # make original item reappear in its place
      @pools[data[:pool_color]].animator.insert_piece(
        data[:index],
        data[:item].name)
    elsif data[:src]
      @board.add_to_group data[:item]
      @board.lower data[:item]
      @animator.movement(data[:item], nil, data[:src], Path::Linear)
    end
    
    @field.run(anim) if anim
  end
  
  def add_controlled_player(player)
    @controlled[player.color] = player
  end
  
  def color=(value)
    @color = value
    @controlled = { @color => self }
  end
    
  def movable?(p)
    ! ! @controlled[@match.state.turn]
  end
  
  def droppable?(color, index)
    ! ! @controlled[@match.state.turn]
  end
end
