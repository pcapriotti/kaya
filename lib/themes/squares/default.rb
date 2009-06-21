require 'themes/theme'
require 'themes/background'

class DefaultBackground
  include Theme
  include Background
  
  theme :name => 'Default',
        :keywords => %w(chess board)
  
  def initialize(opts)
    @squares = opts[:board_size] || opts[:game].size
  end

  def pixmap(size)
    Qt::Image.painted(Qt::Point.new(size.x * @squares.x, size.y * @squares.y)) do |p|
      (0...@squares.x).each do |x|
        (0...@squares.y).each do |y|
          rect = Qt::RectF.new(size.x * x, size.y * y, size.x, size.y)
          color = if (x + y) % 2 == 0
            Qt::Color.new(0x6b, 0x82, 0x9c)
          else
            Qt::Color.new(0xb8, 0xc0, 0xc0)
          end
          p.fill_rect(rect, Qt::Brush.new(color))
        end
      end
    end.to_pix
  end
end
