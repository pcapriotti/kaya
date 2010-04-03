# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkits/qt'

module KDE
  def self.ki18n(str)
    str
  end

  def self.i18n(str)
    str
  end
  
  def self.i18nc(context, str)
    str
  end
end

Qt::XmlGuiWindow = Qt::MainWindow

class Qt::UrlRequester < Qt::LineEdit
  def url=(val)
    self.text = val.to_string
  end
  
  def url
    Qt::Url.new(text)
  end
end

class Qt::MainWindow
  attr_reader :gui
  
  def initialize(parent)
    super(parent)
    
    setToolButtonStyle(Qt::ToolButtonFollowStyle)
    
    # create basic GUI
    @gui = Qt::gui(:qt_base) do |g|
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
        mb.menu(:help, :text => KDE::i18n("&Help")) do |m|
          m.action :about
          m.action :about_qt
        end
      end
      g.tool_bar(:mainToolBar, :text => KDE::i18n("&Main toolbar")) do |tb|
        tb.action :open_new
        tb.action :open
        tb.action :save
      end
    end
  end
  
  def setGUI(gui)
    regular_action(:about, :text => KDE::i18n("&About")) do
      Qt::MessageBox.about(nil,
                           $qApp.data[:name],
                           [$qApp.data[:description],
                            $qApp.data[:copyright]].join("\n"))
    end
    regular_action(:about_qt, :text => KDE::i18n("About &Qt")) { $qApp.about_qt }
    
    @gui.merge!(gui)
    Qt::GuiBuilder.build(self, @gui)
    
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
  include Layoutable
  
  def setGUI(gui)
    self.window_title = gui.opts[:caption]
    layout = Qt::VBoxLayout.new(self)
    widget = Qt::Widget.new(self)
    widget.owner = self
    widget.setGUI(gui)
    buttons = Qt::DialogButtonBox.new
    buttons.add_button(Qt::DialogButtonBox::Ok)
    buttons.add_button(Qt::DialogButtonBox::Cancel)
    layout.add_widget(widget)
    layout.add_widget(buttons)
    
    buttons.on(:accepted) { fire :ok_clicked; accept }
    buttons.on(:rejected) { reject }
  end
end

class Qt::XMLGUIClient < Qt::Object
  def setGUI(gui)
    parent.gui.merge!(gui)
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
    text, icon_name = Qt::STD_ACTIONS[name]
    if text
      icon = Qt::Icon.from_theme(icon_name)
      a = Qt::Action.new(icon, text, action_parent)
      add_action(name, a)
      a.on(:triggered, &blk)
      a
    end
  end
  
  def regular_action(name, opts = { }, &blk)
    a = Qt::Action.new(opts[:text], action_parent)
    add_action(name, a)
    a.on(:triggered, &blk)
    if (opts[:icon])
      a.icon = Qt::Icon.from_theme(opts[:icon])
    end
    a
  end
  
  def action_parent
    self
  end
end

module Qt
  STD_ACTIONS = {
    :open_new => [KDE::i18n("&New..."), 'document-new'],
    :open => [KDE::i18n("&Open..."), 'document-open'],
    :quit => [KDE::i18n("&Quit"), 'application-exit'],
    :save => [KDE::i18n("&Save"), 'document-save'],
    :save_as => [KDE::i18n("S&ave as..."), 'document-save-as'],
    :undo => [KDE::i18n("&Undo"), 'edit-undo'],
    :redo => [KDE::i18n("&Redo"), 'edit-redo']
  }
  
  def self.gui(name, opts = { }, &blk)
    self.autogui(name, opts, &blk)
  end
end

class Qt::Application
  attr_accessor :data
  
  def self.init(data)
    new(ARGV).tap do |app|
      app.application_name = data[:id]
      app.organization_name = data[:id]
      app.data = data
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
    Qt::Settings::Group.new(Qt::Settings.new, "")
  end
end

class Qt::Settings
  class Group
    def initialize(settings, prefix)
      @settings = settings
      @prefix = prefix
    end
    
    def exists
      in_group do
        not @settings.all_keys.empty?
      end
    end
    
    def delete_group
      @settings.remove(@prefix)
    end
      
    def group(name)
      Group.new(@settings, prefixed(name))
    end
    
    def write_entry(key, value)
      @settings.set_value(prefixed(key), 
                          Qt::Variant.new(value))
    end
    
    def read_entry(key, default_value = nil)
      @settings.value(prefixed(key)).toString || default_value
    end
    
    def sync
      @settings.sync
    end
    
    def group_list
      in_group do
        @settings.child_groups
      end
    end
    
    def entry_map
      in_group do
        @settings.child_keys.inject({}) do |res, key|
          res[key] = @settings.value(key).toString
          res
        end
      end
    end
    
    def each_group
      names = in_group do
        @settings.child_groups
      end
      names.each do |name|
        yield group(name)
      end
    end
    
    def name
      if @prefix =~ /\/([^\/]+)$/
        $1
      else
        @prefix
      end
    end
    
    private
    
    def prefixed(key)
      if @prefix.empty?
        key
      else
        [@prefix, key].join('/')
      end
    end
    
    def in_group
      @settings.begin_group(@prefix)
      result = yield
      @settings.end_group
      result
    end
  end
end

class Qt::TabWidget
  include Layoutable
end

class Qt::Process
  def output_channel_mode=(val)
    case val
    when :only_stdout
      setProcessChannelMode(Qt::Process::SeparateChannels)
      setReadChannel(Qt::Process::StandardOutput)
    else
      raise "Unsupported output mode #{val}"
    end
  end
  
  def self.split_args(str)
    str.split(/\s+/)
  end
  
  def run(path, args)
    start(path, args)
  end
end
