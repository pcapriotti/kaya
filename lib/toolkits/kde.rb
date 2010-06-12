# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkits/qt'
require 'builder'
begin 
  require 'kio' 
rescue LoadError
end

class KDE::Dialog
  include Layoutable
  
  def setGUI(gui)
    self.caption = gui.opts[:caption]
    widget = Qt::Widget.new(self)
    widget.owner = self
    widget.setGUI(gui)
    self.main_widget = widget
  end
end

class KDE::Application
  # 
  # Initialize an application.
  # 
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
      data[:options].each do |args|
        case args.size
        when 2
          opts.add(args[0], args[1])
        when 3
          opts.add(args[0], args[1], args[2])
        end
      end
      KDE::CmdLineArgs.add_cmd_line_options opts
    end

    KDE::Application.new
  end
end

class KDE::CmdLineArgs
  def [](i)
    arg(i)
  end
end

class KDE::ActionCollection  
  def []=(name, action)
    unless action.is_a? KDE::Action
      orig_action = action
      action = KDE::Action.new(action.text, action.parent)
      action.icon = orig_action.icon
      action.checkable = orig_action.checkable
      action.checked = orig_action.checked
      action.on(:triggered) { orig_action.trigger }
      orig_action.on(:changed) { action.checked = orig_action.checked }
    end
    add_action(name.to_s, action)
  end
end

class KDE::XmlGuiWindow
  def setGUI(gui)
    KDE::with_xml_gui(gui) do |file|
      setupGUI(KDE::XmlGuiWindow::Default, file)
    end
  end
  
  def saveGUI
  end
end

class KDE::XMLGUIClient
  def setGUI(gui)
    KDE::with_xml_gui(gui) do |file|
      setXMLFile(file)
    end
  end
end

module ActionHandler
  def std_action(action, opts = {}, &blk)
    target, slot = get_slot(opts[:slot], &blk)
    KDE::StandardAction.method_missing(action, target, slot, action_collection)
  end
  
  def get_slot(s = nil, &blk)
    target, slot = if block_given?
      [Qt::SignalBlockInvocation.new(action_parent, blk, 'invoke()'), SLOT('invoke()')]
    else
      [action_parent, SLOT(s)]
    end
  end
  
  def regular_action(name, opts, &blk)
    KDE::Action.new(KDE::Icon.from_theme(opts[:icon]), 
                    opts[:text], action_parent).tap do |a|
      action_collection.add_action(name.to_s, a)  
      a.connect(SIGNAL('triggered(bool)'), &blk)
    end
  end
  
  def action_parent
    self
  end
end

class KDE::Icon
  def self.from_theme(name)
    if name
      new(name.to_s)
    else
      new
    end
  end
end

class KDE::ConfigGroup
  def each_group
    group_list.each do |g|
      yield group(g)
    end
  end
end

module KDE
  def self.gui(name, &blk)
    "<!DOCTYPE kpartgui SYSTEM \"kpartgui.dtd\">\n" + 
    GuiBuilder.new.gui({ :version => 2, :name => name }, &blk)
  end
  
  def self.with_xml_gui(xml, &blk)
    tmp = TemporaryFile.new
    tmp.open
    
    ::File.open(tmp.file_name, 'w') do |f|
      f.write(xml)
    end
    blk[tmp.file_name]
  ensure
    tmp.close
    ::File.unlink(tmp.file_name)
  end
  
  class GuiBuilder < Builder::XmlMarkup
    def initialize
      super
      @action_opts = { }
    end

    def menu_bar(&blk)
      MenuBar(&blk)
    end
    
    def menu(name, opts = {}, &blk)
      Menu(:name => name) do |m|
        m.text(opts[:text]) if opts[:text]
        blk[m] if block_given?
      end
    end
    
    def action(name, opts = {})
      Action(opts.merge(@action_opts).merge(:name => name))
    end
    
    def separator
      self.Separator
    end
    
    def tool_bar(name, opts = { }, &blk)
      ToolBar(:name => name) do |tb|
        tb.text(opts[:text]) if opts[:text]
        blk[tb] if block_given?
      end
    end
    
    def action_list(name)
      ActionList(:name => name)
    end
    
    def group(name, &blk)
      if block_given?
        @action_opts = { :group => name }
        blk[self]
        @action_opts = { }
      else
        DefineGroup(:name => name)
      end
    end
  end
end

class KDE::TabWidget
  include Layoutable
end

class KDE::Process
  def output_channel_mode=(value)
    c = self.class.const_get("#{value.to_s.capitalize.camelize}Channel")
    setOutputChannelMode(c)
  end
  
  def self.split_args(str)
    KDE::Shell.split_args(str)
  end
  
  def run(path, args)
    set_program(path, args)
    start
  end
end

def KDE.download_tempfile(url, parent)
  result = ""
  if KIO::NetAccess.download(url, result, parent)
    result
  end
end
