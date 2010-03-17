require 'korundum4'
require 'toolkits/qt'

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
    icon = if opts[:icon]
      case opts[:icon]
      when Qt::Icon
        opts[:icon]
      else
        KDE::Icon.new(opts[:icon].to_s)
      end
    else
      KDE::Icon.new
    end
    
    KDE::Action.new(icon, opts[:text], action_parent).tap do |a|
      action_collection.add_action(name.to_s, a)  
      a.connect(SIGNAL('triggered(bool)'), &blk)
    end
  end
  
  def action_parent
    self
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
    def menu_bar(&blk)
      MenuBar(&blk)
    end
    
    def menu(name, text = nil, &blk)
      Menu(:name => name) do |m|
        m.text(text) if text
        blk[m] if block_given?
      end
    end
    
    def action(name, opts = {})
      Action(opts.merge(:name => name))
    end
    
    def separator
      self.Separator
    end
    
    def tool_bar(name, text = nil, &blk)
      ToolBar(:name => name) do |tb|
        tb.text(text) if text
        blk[tb] if block_given?
      end
    end
    
    def action_list(name)
      ActionList(:name => name)
    end
    
    def group(name)
      DefineGroup(:name => name)
    end
  end
end
