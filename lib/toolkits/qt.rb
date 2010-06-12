# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require 'descriptor'
require 'toolkits/qt_gui_builder'

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
    str = toString
    Marshal.load(str) if str
  end
end

class Qt::ByteArray
  def self.from_hex(str)
    new([str.gsub(/\W+/, '')].pack('H*'))
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

class Qt::MetaObject
  def create_signal_map
    map = {}
    (0...methodCount).map do |i|
      m = method(i)
      if m.methodType == Qt::MetaMethod::Signal
        sign = m.signature 
        sign =~ /^(.*)\(.*\)$/
        sig = $1.underscore.to_sym
        val = [sign, m.parameterTypes.size]
        map[sig] ||= []
        map[sig] << val
      end
    end
    map
  end
end

class Qt::Base
  include Observable
  
  def on(sig, opts = {}, &blk)
    raise "Only symbols are supported as signals" unless sig.is_a?(Symbol)
    candidates = if is_a? Qt::Object
      self.signal_map[sig]
    end
    if candidates
      if candidates.size > 1
        # find candidate with the correct arity
        arity = blk.arity
        if blk.arity == -1
          # take first
          candidates = [candidates.first]
        else
          candidates = candidates.find_all{|s| s[1] == arity }
        end
      end
      if candidates.size > 1
        raise "Ambiguous overload for #{sig} with arity #{arity}"
      elsif candidates.empty?
        raise "No overload for #{sig} with arity #{blk.arity}"
      end
      sign = candidates.first[0]
      connect(SIGNAL(sign), &blk)
    else
      observe(sig, &blk)
    end
  end

  def in(interval, &blk)
    Qt::Timer.in(interval, self, &blk)
  end

  def run_later(&blk)
    self.in(0, &blk)
  end
  
  def signal_map
    self.class.signal_map(self)
  end
  
  def self.signal_map(obj)
    @signal_map ||= self.create_signal_map(obj)
  end
  
  def self.create_signal_map(obj)
    obj.meta_object.create_signal_map
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

class Qt::FileDialog
  def self.get_open_url(dir, filter, parent, caption)
    filename = get_open_file_name(parent, caption, dir.to_local_file, filter)
    Qt::Url.from_local_file(filename)
  end
  
  def self.get_save_url(dir, filter, parent, caption)
    filename = get_save_file_name(parent, caption, dir.to_local_file, filter)
    Qt::Url.from_local_file(filename)
  end
end

class Qt::Url
  def is_local_file
    true
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

module Layoutable
  attr_writer :owner
  attr_accessor :main_layout
  
  def add_layout(layout)
    self.layout = layout
    owner.main_layout = layout
  end
  
  def add_accessor(name, result)
    owner.metaclass_eval do
      define_method(name) { result }
    end
  end
  
  def buddies
    @buddies ||= { }
  end
  
  def owner
    @owner || self
  end
end

class Qt::Widget
  include Layoutable
  
  def setGUI(gui)
    Qt::GuiBuilder.build(self, gui)
    buddies.each do |label, buddy|
      label.buddy = owner.__send__(buddy)
    end
  end
end

class KDE::ComboBox
  include ListLike
  
  Item = Struct.new(:get)
  
  def create_item(text, data)
    add_item(text, Qt::Variant.from_ruby(data))
  end

  def current_item
    item(current_index)
  end
  
  def item(i)
    Item.new(item_data(i).to_ruby)
  end
  
  def self.create_signal_map(obj)
    super(obj).tap do |m|
      m[:current_index_changed] = [['currentIndexChanged(int)', 1]]
    end
  end
end

class KDE::TabWidget
  def self.create_signal_map(obj)
    super(obj).tap do |m|
      m[:current_changed] = [['currentChanged(int)', 1]]
    end
  end
end

def KDE.download_tempfile(url, parent)
  url.to_local_file
end
