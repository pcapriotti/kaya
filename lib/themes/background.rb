require 'ext/loader'

module Background
  HALO_DELTA = 0.1
  def halo(size, color)
    lines = [[[HALO_DELTA, HALO_DELTA], [1.0 - HALO_DELTA, HALO_DELTA]],
             [[HALO_DELTA, 1.0 - HALO_DELTA], [1.0 - HALO_DELTA, 1.0 -HALO_DELTA]],
             [[HALO_DELTA, HALO_DELTA], [HALO_DELTA, 1.0 - HALO_DELTA]],
             [[1.0 - HALO_DELTA, HALO_DELTA], [1.0 - HALO_DELTA, 1.0 - HALO_DELTA]]]
    img = Qt::Image.painted(size) do |p|
      lines.each do |src, dst|
        src = Qt::PointF.new(src[0] * size.x, src[1] * size.y)
        dst = Qt::PointF.new(dst[0] * size.x, dst[1] * size.y)
        p.pen = Qt::Pen.new(Qt::Brush.new(color), size.x * HALO_DELTA)
        p.draw_line Qt::LineF.new(src, dst)
      end
    end
    img.exp_blur(size.x * HALO_DELTA)
    img.to_pix
  end
  
  def selection(size)
    halo(size, Qt::Color.new(0xff, 0x40, 0x40))
  end
  
  def highlight(size)
    halo(size, Qt::Color.new(0x40, 0xff, 0x40))
  end
end
