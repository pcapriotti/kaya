require 'plugins/plugin'

class CoolLayout
  include Plugin
  
  plugin :name => 'Layouts/Cool',
         :interface => :layout
        
  # values relative to unit = 1
  MARGIN = 0.2
  CLOCK_WIDTH = 2.6
  CLOCK_HEIGHT_RATIO = 0.4
        
  def initialize(game)
    @game = game
    @size = @game.size
    @flipped = false
  end
        
  def layout(rect, elements)
    xrel = @size.x + MARGIN * 3 + CLOCK_WIDTH
    yrel = @size.y + MARGIN * 2
    unit = [rect.width / xrel, rect.height / yrel].min.floor
    margin = MARGIN * unit
    clock_width = CLOCK_WIDTH * unit
    clock_height = clock_width * CLOCK_HEIGHT_RATIO

    base = Qt::Point.new((rect.width - xrel * unit) / 2,
                          (rect.height - yrel * unit) / 2)
    
    board_rect = Qt::Rect.new(
      base.x + margin, base.y + margin,
      @size.x * unit, @size.y * unit)
    elements[:board].flip(@flipped)
    elements[:board].set_geometry(board_rect)

    pool_height = (board_rect.height - margin * (@game.players.size - 1)) / 
                  @game.players.size
    offy = base.y
    flip = false
    players = @game.players
    players = players.reverse unless @flipped
    players.each do |player|
      r_pool, r_clock = if flip
        [Qt::Rect.new(
            board_rect.right + margin,
            offy + margin,
            clock_width,
            pool_height - clock_height - margin),
          Qt::Rect.new(
            board_rect.right + margin,
            offy + margin + pool_height - clock_height,
            clock_width,
            clock_height)]
      else
        [Qt::Rect.new(
            board_rect.right + margin,
            offy + margin * 2 + clock_height,
            clock_width,
            pool_height - clock_height - margin),
          Qt::Rect.new(
            board_rect.right + margin,
            offy + margin,
            clock_width,
            clock_height)]
      end
      unless elements[:pools].empty?
        elements[:pools][player].flip(flip)
        elements[:pools][player].set_geometry(r_pool)
      end
      elements[:clocks][player].set_geometry(r_clock)
      offy = offy + margin + pool_height
      flip = !flip
    end
  end
  
  def flip(value)
    @flipped = value
  end
  
  def flipped?
    @flipped
  end
end
