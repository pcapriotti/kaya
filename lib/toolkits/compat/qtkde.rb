KDE = Qt

Qt::XmlGuiWindow = Qt::MainWindow
class Qt::MainWindow
  attr_reader :tmp_menu
  
  def initialize(parent)
    super(parent)
    @tmp_menu = Qt::Menu.new("Temp")
    menu_bar.add_menu(@tmp_menu)
  end
  
  def action_collection
    self
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
  def add_action(name, a)
    # fixme
    action_parent.tmp_menu.add_action(a)
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
  
  def self.gui(name)
    ""
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
