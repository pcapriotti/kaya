require 'plugins/plugin'

class HelloWorldPlugin
  include Plugin
  include ActionProvider

  plugin :name => 'Hello World',
         :interface => :action_provider

  def initialize
    action(:hello_world,
           :text => KDE.i18n('Say &Hello World')) do |parent|
      parent.console.append("Hello world")
    end
  end

  def gui
    KDE::gui(:hello_world) do |g|
      g.menubar do |mb|
        mb.menu(:gameMenu) do |m|
          m.action :hello_world
        end
      end
    end
  end
end
