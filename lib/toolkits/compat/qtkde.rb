KDE = Qt

Qt::XmlGuiWindow = Qt::MainWindow
class Qt::MainWindow
  def action_collection
    self
  end
end


Qt::XMLGUIClient = Qt::Object

module ActionHandler
  def add_action(*args)
  end
  
  def std_action(*args)
  end
  
  def regular_action(*args)
  end
end

module Qt
  def self.gui(name)
    ""
  end
  
  def self.with_xml_gui(*args)
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
