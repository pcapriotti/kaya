require 'observer_utils'
require 'history'
require 'board/pool_animator'
require 'clock'

class Controller
  include Observer
  
  attr_reader :history
  
  def initialize(scene, elements, game, history)
    @scene = scene
    @board = elements[:board]
    @pools = elements[:pools]
    @clocks = elements[:clocks]

    @game = game
    @history = history
    @animator = @game.animator.new(@board)
    @field = AnimationField.new(20)
    @board.reset(history.state.board)
    
    c = self
    @board.observe(:click) {|p| c.on_board_click(p) }
    @board.observe(:drag) {|data| c.on_board_drag(data) }
    @board.observe(:drop) {|data| c.on_board_drop(data) }
    @pools.each do |color, pool|
      pool.observe(:drag) {|data| c.on_pool_drag(color, data) }
      pool.observe(:drop) {|data| c.on_pool_drop(color, data) }
    end
    
    @clocks.each do |color, clock|
      clock.clock = Clock.new(300, 0, nil)
      clock.data = { :color => color }
    end
    
    @clocks[@game.players.first].active = true
  end
  
  def on_board_click(p)
    state = @history.state
    if @board.selection
      move = @game.policy.new_move(state, @board.selection, p)
      validate = @game.validator.new(state)
      if validate[move]
        perform! move
      end
      
      @board.selection = nil
    elsif @game.policy.movable?(state, p) and movable?(p)
      @board.selection = p
    end
  end
  
  def perform!(move, opts = {})
    @clocks[@history.state.turn].stop
    state = @history.state.dup
    state.perform! move
    @history.add_move(state, move)
    animate(:forward, state, move, opts)
    @board.highlight(move)
    
    @clocks[@history.state.turn].start
  end
  
  def back
    state, move = @history.back
    animate(:back, state, move)
    @board.highlight(@history.move)
  rescue History::OutOfBound
    puts "error: first move"
  end
  
  def forward
    state, move = @history.forward
    animate(:forward, state, move)
    @board.highlight(move)
  rescue History::OutOfBound
    puts "error: last move"
  end
  
  def animate(direction, state, move, opts = {})
    anim = @animator.send(direction, state, move, opts)
    @field.run anim
    
    update_pools
  end
  
  def update_pools
    @pools.each do |color, pool|
      anim = pool.animator.warp(@history.state.pool(color))
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
        move = @game.policy.new_move(@history.state, data[:src], data[:dst])
        validate = @game.validator.new(@history.state)
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
      move = @game.policy.new_move(@history.state, nil,
        data[:dst], :dropped => data[:item].name)
      validate = @game.validator.new(@history.state)
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
    if @game.policy.movable?(@history.state, data[:src]) and 
       movable?(data[:src])
      @board.raise data[:item]
      @board.remove_from_group data[:item]
      @board.selection = nil
      @scene.on_drag(data)
    end
  end
  
  def on_pool_drag(color, data)
    if @game.policy.droppable?(@history.state, color, data[:index]) and 
       droppable?(color, data[:index])
       
      # replace item with a correctly sized one
      item = @board.create_piece(data[:item].name)
      @board.raise item
      @board.remove_from_group item
      anim = @pools[color].animator.remove_piece(data[:index])
      data[:item] = item
      data[:size] = @board.unit
      data[:pool_color] = color
      
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
  
  def movable?(p)
    true
  end
  
  def droppable?(color, index)
    true
  end
end
