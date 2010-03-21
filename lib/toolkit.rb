require 'rubygems' rescue nil
require 'observer_utils'
require 'utils'
require 'builder'

case ($toolkit || :kde)
when :qt
  require 'toolkits/qt'
  require 'toolkits/compat/qtkde'
when :kde
  require 'toolkits/kde'
end

module KDE
  def self.autogui(name, opts = { }, &blk)
    Descriptor.new(:gui, opts.merge(:gui_name => name)).tap do |desc|
      blk[Descriptor::Builder.new(desc)] if block_given?
    end
  end
end
