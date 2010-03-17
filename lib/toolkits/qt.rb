# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'Qt4'

ParseException = Class.new(Exception)

class Qt::Variant
  # 
  # Convert any marshallable ruby object into a QVariant.
  # 
  def self.from_ruby(x)
    new(Marshal.dump(x))
  end

  # 
  # Extract the ruby object contained in a QVariant.
  # 
  def to_ruby
    Marshal.load(toString)
  end
end

class Qt::Painter
  # 
  # Ensure this painter is closed after the block is executed.
  # 
  def paint
    yield self
  ensure
    self.end
  end
  
  # 
  # Execute a block, then restore the painter state to what it
  # was before execution.
  # 
  def saving
    save
    yield self
  ensure
    restore
  end
end

class Qt::Image
  # 
  # Convert this image to a pixmap.
  # 
  def to_pix
    Qt::Pixmap.from_image self
  end
  
  # 
  # Paint on an image using the given block. The block is passed
  # a painter to use for drawing.
  # 
  def self.painted(size, &blk)
    Qt::Image.new(size.x, size.y, Qt::Image::Format_ARGB32_Premultiplied).tap do |img|
      img.fill(0)
      Qt::Painter.new(img).paint(&blk)
    end
  end

  # 
  # Render an svg object onto a new image of the specified size. If id is not
  # specified, the whole svg file is rendered.
  # 
  def self.from_renderer(size, renderer, id = nil)
    img = Qt::Image.painted(size) do |p| 
      if id
        renderer.render(p, id)
      else
        renderer.render(p)
      end
    end
    img
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
  
  def to_f
    Qt::PointF.new(self.x, self.y)
  end
end

class Qt::PointF
  include PrintablePoint
  
  def to_i
    Qt::Point.new(self.x.to_i, self.y.to_i)
  end
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

class Qt::SizeF
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
  
  def to_f
    Qt::RectF.new(self.x, self.y, self.width, self.height)
  end
end

class Qt::RectF
  include PrintableRect
end

class Qt::Pixmap
  # 
  # Render a pixmap from an svg file. See also Qt::Image#renderer.
  # 
  def self.from_svg(size, file, id = nil)
    from_renderer(size, Qt::SvgRenderer.new(file), id)
  end
  
  # 
  # Render a pixmap using an svg renderer. See also Qt::Image#renderer.
  # 
  def self.from_renderer(size, renderer, id = nil)
    Qt::Image.from_renderer(size, renderer, id).to_pix
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
  # 
  # Execute the given block every interval milliseconds and return a timer
  # object. Note that if the timer is garbage collected, the block will not
  # be executed anymore, so the caller should keep a reference to it for as
  # long as needed.
  # To prevent further invocations of the block, use QTimer#stop.
  # 
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

  # 
  # Execute the given block after interval milliseconds. If target is
  # specified, the block is invoked in the context of target.
  # 
  def self.in(interval, target = nil, &blk)
    single_shot(interval,
                Qt::BlockInvocation.new(target, blk, 'invoke()'),
                SLOT('invoke()'))
  end
end

module ListLike
  module ClassMethods
    #
    # Create a list from an array of pairs (text, data)
    # The data for each item can be retrieved using the
    # item's get method.
    # Note that if an array element is not a pair, its
    # value will be used both for the text and for the
    # data.
    # 
    # For example: <tt>list.current_item.get</tt>
    # 
    def from_a(parent, array)
      new(parent).tap do |list|
        list.reset_from_a(array)
      end
    end
  end
  
  #
  # Select the item for which the given block
  # evaluates to true.
  #
  def select_item(&blk)
    (0...count).each do |i|
      if blk[item(i).get]
        self.current_index = i
        break i
      end
    end
    nil
  end
  
  # 
  # Populate the list with values from an array.
  # See also from_a.
  #
  def reset_from_a(array)
    clear
    array.each do |values|
      text, data = if values.is_a?(String)
        [values, values]
      else
        values
      end
      create_item(text, data)
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
end

class Qt::ListWidget
  FROM_A_DATA_ROLE = Qt::UserRole
  include ListLike
  
  class Item < Qt::ListWidgetItem
    def initialize(text, list, data)
      super(text, list)
      set_data(FROM_A_DATA_ROLE, Qt::Variant.from_ruby(data))
    end

    def get
      data(FROM_A_DATA_ROLE).to_ruby
    end
  end
  
  def current_index=(i)
    self.current_row = i
  end

  def create_item(text, data)
    Item.new(text, self, data)
  end
end

module ModelUtils
  # 
  # Helper method to delete model rows from within a block. This method
  # ensures that the appropriate begin/end functions are called.
  # 
  def removing_rows(parent, first, last)
    if first > last
      yield
    else
      begin
        begin_remove_rows(parent || Qt::ModelIndex.new, first, last)
        yield
      ensure
        end_remove_rows
      end
    end
  end
  
  # 
  # Helper method to insert model rows from within a block. This method
  # ensures that the appropriate begin/end functions are called.
  # 
  def inserting_rows(parent, first, last)
    if first > last
      yield
    else
      begin
        begin_insert_rows(parent || Qt::ModelIndex.new, first, last)
        yield
      ensure
        end_insert_rows
      end
    end
  end
end
