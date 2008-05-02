class Qt::Painter
  def paint
    yield self
  ensure
    self.end
  end
end

class Qt::Image
  def to_pix
    Qt::Pixmap.from_image self
  end
end
