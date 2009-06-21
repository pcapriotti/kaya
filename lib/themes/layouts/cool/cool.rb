require 'themes/theme'

class CoolLayout
  include Theme
  
  theme :name => 'Layouts/Cool',
        :keywords => %w(layout)
        
  # values relative to unit = 1
  MARGIN = 0.2
  CLOCK_WIDTH = 2.6
  CLOCK_HEIGHT_RATIO = 0.4
        
  def initialize(opts)
    @game = opts[:game]
    @size = @game.size
    @flipped = false
  end
        
  def layout(rect, elements)
    xrel = @size.x + MARGIN * 3 + CLOCK_WIDTH
    yrel = @size.y + MARGIN * 2
    unit = [rect.width / xrel, rect.height / yrel].min.floor
    margin = MARGIN * unit
    clock_width = CLOCK_WIDTH * unit

    base = Qt::Point.new((rect.width - xrel * unit) / 2,
                          (rect.height - yrel * unit) / 2)
    
    board_rect = Qt::Rect.new(
      base.x + margin, base.y + margin,
      @size.x * unit, @size.y * unit)
    elements[:board].flip(@flipped)
    elements[:board].set_geometry(board_rect)

    if @game.respond_to? :pool
      pool_height = (board_rect.height - margin) / @game.players.size
      offy = base.y
      flip = !@flipped
      pools_rect = @game.players.reverse.map do |player|
        r = Qt::Rect.new(
          board_rect.right + margin,
          offy + margin,
          clock_width,
          pool_height)
        elements[:pools][player].flip(flip = !flip)
        elements[:pools][player].set_geometry(r)
        offy = r.bottom
        r
      end
    end
  end
  
  def flip(value)
    @flipped = value
  end
  
  def flipped?
    @flipped
  end
end
