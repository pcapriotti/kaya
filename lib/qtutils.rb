require 'korundum4'

class Object
  def tap
    yield self
    self
  end
  
  def metaclass
    class << self
      self
    end
  end
  
  def metaclass_eval(&blk)
    metaclass.instance_eval(&blk)
  end
end

class Qt::Painter
  def paint
    yield self
  ensure
    self.end
  end
  
  def saving
    save
    yield self
  ensure
    restore
  end
end

class Qt::Image
  def to_pix
    Qt::Pixmap.from_image self
  end
  
  def self.painted(size, &blk)
    Qt::Image.new(size.x, size.y, Qt::Image::Format_ARGB32_Premultiplied).tap do |img|
      img.fill(0)
      Qt::Painter.new(img).paint(&blk)
    end
  end
end

module PrintablePoint
  def ==(other)
    self.x == other.x and self.y == other.y
  end
  
  def to_s
    "(#{self.x}, #{self.y})"
  end
end

module PrintableRect
  def to_s
    "[#{self.x}, #{self.y} - #{self.width}, #{self.height}]"
  end
end

class Qt::Point
  include PrintablePoint
end

class Qt::PointF
  include PrintablePoint
end

class Qt::Size
  include PrintablePoint
  
  def x
    width
  end
  
  def y
    height
  end
end

class Qt::Rect
  include PrintableRect
end

class Qt::RectF
  include PrintableRect
end

class Qt::Pixmap
  def self.from_svg(size, file, id = nil)
    from_renderer(size, Qt::SvgRenderer.new(file), id)
  end
  
  def self.from_renderer(size, renderer, id = nil)
    img = Qt::Image.painted(size) do |p| 
      if id
        renderer.render(p, id)
      else
        renderer.render(p)
      end
    end
    img.to_pix
  end
end

class Qt::Base
  def self.signal_map(sigmap)
    @signal_map = sigmap
    signals *sigmap.map{|k, v| v || k }
  end

  def self.get_signal(sig)
    (@signal_map || {})[sig] || sig
  end

  def on(sig, &blk)
    connect(SIGNAL(self.class.get_signal(sig)), &blk)
  end  

  def in(interval, &blk)
    Qt::Timer.in(interval, self, &blk)
  end

  def run_later(&blk)
    self.in(0, &blk)
  end
end

class Qt::Timer
  def self.every(interval, &blk)
    time = Qt::Time.new
    time.restart
    
    timer = new
    timer.connect(SIGNAL('timeout()')) { blk[time.elapsed] }
    timer.start(interval)
    # return the timer, so that the caller
    # has a chance to keep it referenced, so
    # that it is not garbage collected
    timer
  end

  def self.in(interval, target = nil, &blk)
    single_shot(interval,
                Qt::BlockInvocation.new(target, blk, 'invoke()'),
                SLOT('invoke()'))
  end
end

class KDE::Application
  def self.init(data)
    about = KDE::AboutData.new(
      data[:id],
      data[:id],
      data[:name],
      data[:version],
      data[:description],
      KDE::AboutData::License_GPL,
      data[:copyright])
    data[:authors].each do |name, email|
      about.addAuthor(name, KDE::LocalizedString.new, email)
    end
    data[:contributors].each do |name, contribution|
      about.addCredit(name, contribution)
    end
    about.bug_address = Qt::ByteArray.new(data[:bug_tracker])
    
    KDE::CmdLineArgs.init(ARGV, about)
    KDE::CmdLineOptions.new.tap do |opts|
      data[:options].each do |opt, desc|
        opts.add(opt, desc)
      end
      KDE::CmdLineArgs.add_cmd_line_options opts
    end

    KDE::Application.new
  end
end

module ActionHandler
  def std_action(action, s = nil, &blk)
    target, slot = if block_given?
      [Qt::BlockInvocation.new(self, blk, 'invoke()'), SLOT(:invoke)]
    else
      [self, SLOT(s)]
    end
    
    KDE::StandardAction.send(action, target, slot, action_collection)
  end
end
