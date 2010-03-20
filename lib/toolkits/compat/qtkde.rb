# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

KDE = Qt

Qt::XmlGuiWindow = Qt::MainWindow
class Qt::MainWindow
  attr_reader :tmp_menu
  
  def initialize(parent)
    super(parent)
    @tmp_menu = Qt::Menu.new("Temp")
    menu_bar.add_menu(@tmp_menu)
  end
end

class Qt::Dialog
  def caption=(val)
    self.window_title = val
  end
end

Qt::XMLGUIClient = Qt::Object

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
    :save_as => lambda {|w| Qt::Action.new(KDE::i18n("S&ave as.."), w) }
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
          add_child(child2.dup) unless merged
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
    end
  end
  
  def self.gui(name, &blk)
    Descriptor.new(:gui, :name => name).tap do |desc|
      blk[Descriptor::Builder.new(desc)] if block_given?
    end
  end
  
  def self.with_xml_gui(*args, &blk)
  end

  def self.ki18n(str)
    str
  end

  def self.i18n(str)
    str
  end
end

class Qt::Application
  def self.init(data)
    new(ARGV)
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
