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
