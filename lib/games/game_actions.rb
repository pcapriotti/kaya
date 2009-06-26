require 'qtutils'

Action = Struct.new(:id, :opts, :action)

module GameActions
  def action(id, opts = {}, &action)
    @action_data ||= []
    @action_data << Action.new(id, opts, action)
  end
  
  def actions(parent, collection, policy)
    actions = (@action_data || []).map{|data| create_action(data, parent, collection, policy) }
    actions
  end
  
  private
  
  def create_action(data, parent, collection, policy)
    icon = if data.opts[:icon]
      KDE::Icon.new(data.opts[:icon])
    else
      KDE::Icon.new
    end
    text = data.opts[:text] || data.id.to_s
    a = KDE::Action.new(icon, text, parent)
    collection.add_action(data.id.to_s, a)
    if data.opts.has_key?(:checked)
      a.checkable = true
      a.checked = data.opts[:checked]
      a.connect(SIGNAL('toggled(bool)')) do |value|
        data.action[value, policy]
      end
    else
      a.on(:triggered) { data.action[policy] }
    end
    a
  end
end
