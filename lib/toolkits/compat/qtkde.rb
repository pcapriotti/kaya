# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

KDE = Qt # wait... what?

module Qt
  def self.ki18n(str)
    str
  end

  def self.i18n(str)
    str
  end
end

require 'toolkits/compat/qt_gui_builder'

Qt::XmlGuiWindow = Qt::MainWindow

class Qt::MainWindow  
  def setGUI(gui)
    # create basic GUI
    basic = Qt::gui(gui.name) do |g|
      g.menu_bar do |mb|
        mb.menu(:file, :text => KDE::i18n("&File")) do |m|
          m.action :open_new
          m.action :open
          m.action :save
          m.action :save_as
          m.separator
          m.merge_point
          m.separator
          m.action :quit
        end
        mb.menu(:edit, :text => KDE::i18n("&Edit")) do |m|
          m.action :undo
          m.action :redo
        end
        mb.merge_point
        mb.menu(:settings, :text => KDE::i18n("&Settings"))
      end
    end
    basic.merge!(gui)
    Qt::GuiBuilder.build(self, basic)
    
    # restore state
    settings = Qt::Settings.new
    state = nil
    geometry = nil
    if settings.contains("mainwindow/state")
      state = settings.value("mainwindow/state").toByteArray
      geometry = settings.value("mainwindow/geometry").toByteArray
    else
      # reasonable default values
      state = Qt::ByteArray.from_hex(%{
        000000ff00000000fd0000000100000000000000b2000002e4fc0200000001fc000000
        33000002e4000000a60100001efa000000010100000002fb0000000e0063006f006e00
        73006f006c00650100000000ffffffff0000005101000005fb00000010006d006f0076
        0065006c0069007300740100000000000000510000004e01000005000002d8000002e4
        00000004000000040000000800000008fc000000010000000200000002000000160067
        0061006d00650054006f006f006c0062006100720100000000ffffffff000000000000
        000000000016006d00610069006e0054006f006f006c004200610072010000007b0000
        03120000000000000000})
      geometry = Qt::ByteArray.from_hex(%{
        01d9d0cb0001000000000000000000000000039400000335000000040000001b000003
        9000000331000000000000})
    end
    restore_geometry(geometry)
    restore_state(state)
  end
  
  def saveGUI
    settings = Qt::Settings.new
    settings.begin_group("mainwindow")
    settings.set_value("geometry", Qt::Variant.new(save_geometry))
    settings.set_value("state", Qt::Variant.new(save_state))
    settings.end_group
    settings.sync
  end
end

class Qt::Dialog
  def caption=(val)
    self.window_title = val
  end
end

class Qt::XMLGUIClient < Qt::Object
  def setGUI(gui)
  end
end

class KDE::ComboBox
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

module ActionHandler
  def action_collection
    @action_collection ||= { }
  end
  
  def add_action(name, a)
    action_parent.action_collection[name] = a
  end
  
  def std_action(name, &blk)
    action_factory = Qt::STD_ACTIONS[name]
    if action_factory
      a = action_factory[action_parent]
      add_action(name, a)
      a.on(:triggered, &blk)
      a
    end
  end
  
  def regular_action(name, opts = { }, &blk)
    a = Qt::Action.new(opts[:text], action_parent)
    add_action(name, a)
    a.on(:triggered, &blk)
    a
  end
  
  def action_parent
    self
  end
end

module Qt
  STD_ACTIONS = {
    :open_new => lambda {|w| Qt::Action.new(KDE::i18n("&New..."), w) },
    :open => lambda {|w| Qt::Action.new(KDE::i18n("&Open..."), w) },
    :quit => lambda {|w| Qt::Action.new(KDE::i18n("&Quit"), w) },
    :save => lambda {|w| Qt::Action.new(KDE::i18n("&Save"), w) },
    :save_as => lambda {|w| Qt::Action.new(KDE::i18n("S&ave as..."), w) },
    :undo => lambda {|w| Qt::Action.new(KDE::i18n("&Undo"), w) },
    :redo => lambda {|w| Qt::Action.new(KDE::i18n("&Redo"), w) },
  }
  
  class Descriptor
    attr_reader :name, :opts, :children
    
    def initialize(name, opts = { })
      @name = name
      @opts = opts
      @children = []
    end
    
    def add_child(desc)
      @children << desc
    end
    
    def merge_child(desc)
      if @opts[:merge_point]
        @children.insert(@opts[:merge_point], desc)
        @opts[:merge_point] += 1
      else
        add_child(desc)
      end
    end
    
    def to_sexp
      "(#{@name} #{@opts.inspect}#{@children.map{|c| ' ' + c.to_sexp}.join})"
    end
    
    def merge!(other, prefix = "")
      if name == other.name and
          opts[:name] == other.opts[:name]
        other.children.each do |child2|
          merged = false
          children.each do |child|
            if child.merge!(child2, prefix + "    ")
              merged = true
              break
            end
          end
          merge_child(child2.dup) unless merged
        end
        true
      else
        false
      end
    end
    
    class Builder
      attr_reader :__desc__
      private :__desc__
      
      def initialize(desc)
        @__desc__ = desc
      end
      
      def method_missing(name, *args, &blk)
        opts = if args.empty?
          { }
        elsif args.size == 1
          { :name => args.first }
        else
          args[-1].merge(:name => args.first)
        end
        child = Descriptor.new(name, opts)
        blk[self.class.new(child)] if block_given?
        __desc__.add_child(child)
      end
      
      def merge_point
        @__desc__.opts[:merge_point] = @__desc__.children.size
      end
    end
  end
  
  def self.gui(name, &blk)
    Descriptor.new(:gui, :gui_name => name).tap do |desc|
      blk[Descriptor::Builder.new(desc)] if block_given?
    end
  end
end

class Qt::Application
  def self.init(data)
    new(ARGV).tap do |app|
      app.application_name = data[:id]
      app.organization_name = data[:id]
    end
  end
end

class KDE::CmdLineArgs
  def self.parsed_args
    ARGV
  end
end

class KDE::Global
  def self.config
    Qt::Settings.new
  end
end

class Qt::Settings
  module GroupMixin
    def exists
      false
    end
    
    def delete_group
    end
      
    def group(name)
      Group.new
    end
    
    def write_entry(*args)
    end
    
    def sync
    end
    
    def group_list
      []
    end
  end
  
  include GroupMixin
  
  class Group
    include GroupMixin
  end
end
